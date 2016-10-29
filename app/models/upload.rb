class Upload < ApplicationRecord
  include DirectUpload

  FILTER_FIELDS = %w( type name taken_at imported_at )

  default_scope { where.not(state: 'destroy') }

  belongs_to :uploader, class_name: 'User'
  belongs_to :library
  has_many :tags, dependent: :destroy, autosave: true

  delegate :tag_new, :tag_aspect, :tag_date, :tag_camera, :tag_location,
    to: :library, prefix: true

  direct_upload :file
  serialize :metadata
  reverse_geocoded_by :latitude, :longitude, address: :location do |model, results|
    if geo = results.first
      model.location = [ geo.city, geo.province_code, geo.country ].compact.join(', ')
    end
  end

  validates :type, presence: true
  validates :library, presence: true
  validates :uploader, presence: true
  validates :name, presence: true
  validates :modified_at, presence: true
  validates :size, presence: true, numericality: { greater_than: 0 }
  validates :mime, presence: true, format: /\A\w+\/\w+\z/
  validates :md5sum, allow_nil: true, format: /\A[0-9a-f]{32}\z/, uniqueness: {
    scope: [ :library_id, :size, :mime ],
    message: 'has already been uploaded'
  }
  validates :state, inclusion: %w( upload process ready fail destroy )
  validates :imported_at, presence: true
  validates :latitude, allow_nil: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, allow_nil: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :rotate, inclusion: [ 0, 90, 180, 270 ]

  scope :deleted, -> { where.not(deleted_at: nil) }

  after_validation :reverse_geocode, if: -> { latitude_changed? || longitude_changed? }
  after_commit :destroy_file_buffers, if: -> { persisted? && file? && previous_changes[:file].present? }

  after_initialize :set_initial_state, if: :new_record?
  def set_initial_state
    self.state ||= 'upload'
  end

  after_create :auto_tag_new
  def auto_tag_new
    self.library.tag_new.to_s.scan(/#{Tag::TAG_PATTERN}/).each do |tag|
      self.tag(name: tag)
    end
  end

  after_save :auto_tag_aspect, if: -> { (self.width_changed? || self.height_changed?) && self.library_tag_aspect }
  def auto_tag_aspect
    return unless self.width? || self.height?

    ratio = self.width.to_f / self.height
    tag =
      if ratio >= 3
        'panoramic'
      elsif ratio > 1.1
        'landscape'
      elsif ratio > 0.9
        'square'
      else
        'portrait'
      end
    self.tag(name: tag, kind: 'aspect')
  end

  after_save :auto_tag_date, if: -> { self.taken_at_changed? && self.library_tag_date }
  def auto_tag_date
    return unless self.taken_at?
    self.tag(name: self.taken_at.year.to_s, kind: 'date')
    self.tag(name: self.taken_at.strftime('%B').downcase, kind: 'date') # month
  end

  after_save :auto_tag_location, if: -> { self.location_changed? && self.library_tag_location }
  def auto_tag_location
    if self.location?
      self.location.split(/, */).each do |part|
        self.tag(name: part.downcase.gsub(/ +/, '-'), kind: 'location')
      end
    else
      self.tag(name: 'no-location', kind: 'location')
    end
  end

  before_update :auto_set_md5sum, unless: :md5sum?
  def auto_set_md5sum
    self.md5sum = Digest::MD5.hexdigest(File.read(self.file.path)) if self.file?
  end

  after_commit :backup
  def backup
    if CARRIERWAVE_STORAGE == :file && S3
      if self.destroyed?
        BackupDestroyJob.set(priority: 1).perform_later(@destroy_paths)
      else
        BackupUploadJob.set(priority: 0).perform_later(self.id, 'original')
        BackupUploadJob.set(priority: 1).perform_later(self.id, self.file.versions.keys.map(&:to_s))
      end
    end
  end

  before_destroy :cache_destroy_paths
  def cache_destroy_paths
    if CARRIERWAVE_STORAGE == :file
      file = self.file
      @destroy_paths = [ file.path ] + file.versions.values.map(&:path)
    end
  end

  def self.with_tags tags
    tags.inject(self.all) do |scope, tag|
      if negative = tag.starts_with?('-')
        tag = tag[1..-1]
      end

      sub = Tag.where(name: tag).select(:upload_id)
      scope.where("uploads.id #{negative ? 'NOT IN' : 'IN'} (#{sub.to_sql})")
    end
  end

  def self.with_filters filters
    JSON.parse(filters).inject(self.all) do |scope, filter|
      field, op, value = filter['field'], filter['op'], filter['value']
      if field.in? FILTER_FIELDS
        value = (Time.zone.parse(value).to_date rescue nil) if field.ends_with?('_at')
        op, value =
          case op
          when 'eq' then [ '=', value ]
          when 'ne' then [ '!=', value ]
          when 'le' then [ '<=', value ]
          when 'lt' then [ '<', value ]
          when 'ge' then [ '>=', value ]
          when 'gt' then [ '>', value ]
          when 'contains' then [ 'ILIKE', "%#{value.gsub(/([%_\\])/, '\\\\\1')}%" ]
          else [ nil, nil ]
          end

        if op && value.present?
          scope.where("uploads.#{field} #{op} ?", value)
        else
          scope
        end
      else
        scope
      end
    end
  end

  def self.random_order(seed)
    prng = Random.new(seed)
    cols = []
    while cols.size < 5
      col = prng.rand(32) + 1
      cols.push(col) unless cols.index(col)
    end

    self.order(
      *(cols.map { |col| "SUBSTR(uploads.md5sum, #{col}, 1)" }),
      :id
    )
  end

  def tag(attributes)
    name = attributes[:name]
    if existing = self.tags.find { |tag| tag.name == name }
      existing.update(attributes)
    else
      self.tags.create(attributes)
    end
  end

  def file_size
    self.size
  end

  def file_block_size
    if self.destroyed?
      self.block_size || self.uploader.upload_block_size
    else
      self.block_size ||= self.uploader.upload_block_size
    end
  end

  def fetch_and_process_file_in_background
    self.update_column(:state, 'process')
    super
  end

  def process_file_data(blocks, final_state = 'ready')
    file = Tempfile.new(self.name.gsub(/\s+/, '_').split(/(?=\.[^.]+\z)/), encoding: 'BINARY')
    begin
      blocks.each do |block|
        if block == :not_found
          self.update_attributes!(state: 'fail')
          return
        else
          file.write(block)
        end
      end

      if ! self.update_attributes(state: final_state, file: file)
        self.destroy # invalid, md5sum conflict
      end
    ensure
      file.close
      file.unlink
    end
  end

  def self.new(attributes = {}, &block)
    return super unless self == Upload
    klass = case attributes[:mime]
            when /\Aimage\// then Photo
            when /\Avideo\// then Video
            else return super
            end
    klass.new attributes, &block
  end

  def tags=(new_tags)
    if new_tags.is_a?(Array) && new_tags.all? { |tag| tag.is_a? String }
      self.tags.each do |existing|
        existing.mark_for_destruction if new_tags.delete(existing.name).nil?
      end
      new_tags.each do |new_tag|
        self.tags.build(name: new_tag)
      end
    else
      super
    end
  end

  def recreate_versions!
    begin
      uploader = self.file
      uploader.cache_stored_file!
      uploader.retrieve_from_cache!(uploader.cache_name)
      uploader.recreate_versions!
      self.save!
    rescue => e
      Rails.logger.warn "#{self.class.to_s}(#{self.id})#recreate_versions_for(#{column.inspect}): #{e.to_s}"
    end
  end

end
