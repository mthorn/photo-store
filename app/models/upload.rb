class Upload < ActiveRecord::Base
  include DirectUpload

  belongs_to :uploader, class_name: 'User'
  belongs_to :library

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
  validates :state, inclusion: %w( upload process ready fail )
  validates :imported_at, presence: true

  after_initialize :set_initial_state, if: :new_record?
  after_create :create_direct_upload_for_file, unless: :file?

  def set_initial_state
    self.state ||= 'upload'
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
