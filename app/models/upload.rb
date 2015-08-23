class Upload < ActiveRecord::Base
  include DirectUpload

  default_scope { where.not(state: 'destroy') }

  belongs_to :uploader, class_name: 'User'
  belongs_to :library
  has_many :tags, dependent: :destroy

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
  validates :name, presence: true, uniqueness: {
    scope: [ :library_id, :size, :mime ],
    message: 'has already been uploaded'
  }
  validates :modified_at, presence: true
  validates :size, presence: true, numericality: { greater_than: 0 }
  validates :mime, presence: true, format: /\A\w+\/\w+\z/
  validates :state, inclusion: %w( upload process ready fail destroy )
  validates :imported_at, presence: true
  validates :latitude, allow_nil: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, allow_nil: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  scope :deleted, -> { where.not(deleted_at: nil) }

  after_validation :reverse_geocode, if: -> { latitude_changed? || longitude_changed? }

  after_initialize :set_initial_state, if: :new_record?
  def set_initial_state
    self.state ||= 'upload'
  end

  after_create :auto_tag_new
  def auto_tag_new
    self.library.tag_new.to_s.scan(/\S+/).each do |tag|
      self.tags.create(name: tag)
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
    self.tags.create(name: tag, kind: 'aspect')
  end

  after_save :auto_tag_date, if: -> { self.taken_at_changed? && self.library_tag_date }
  def auto_tag_date
    return unless self.taken_at?
    self.tags.create(name: self.taken_at.year.to_s, kind: 'date')
    self.tags.create(name: self.taken_at.strftime('%B').downcase, kind: 'date') # month
  end

  after_save :auto_tag_location, if: -> { self.location_changed? && self.library_tag_location }
  def auto_tag_location
    return unless self.location?
    self.location.split(/, */).each do |part|
      self.tags.create(name: part.downcase.gsub(/ +/, '-'), kind: 'location')
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

  def process_file_data blocks
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

      self.update_attributes!(state: 'ready', file: file)
    ensure
      file.close
      file.unlink
    end
  end

  def self.new(attributes = {}, options = {}, &block)
    return super unless self == Upload
    klass = case attributes[:mime]
            when /\Aimage\// then Photo
            when /\Avideo\// then Video
            else return super
            end
    klass.new attributes, options, &block
  end

end
