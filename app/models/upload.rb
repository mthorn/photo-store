class Upload < ActiveRecord::Base
  include DirectUpload

  default_scope { where.not(state: 'destroy') }

  belongs_to :uploader, class_name: 'User'
  belongs_to :library
  has_many :tags, dependent: :destroy

  delegate :tag_new, :tag_aspect, :tag_date, :tag_camera,
    to: :library, prefix: true

  direct_upload :file
  serialize :metadata

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

  scope :deleted, -> { where.not(deleted_at: nil) }

  after_create :create_direct_upload_for_file, unless: :file?

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

  after_save :auto_tag_aspect, if: -> { width? && height? && width_changed? && height_changed? && library_tag_aspect }
  def auto_tag_aspect
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
    self.tags.create(name: tag)
  end

  def fetch_and_process_file_in_background
    self.update_column(:state, 'process')
    super
  end

  def process_file file
    if file == :not_found
      self.update_attributes!(state: 'fail')
    else
      self.update_attributes!(state: 'ready', file: file)
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

  def file_name
    self.name
  end

end
