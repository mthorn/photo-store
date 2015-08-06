class Upload < ActiveRecord::Base
  include DirectUpload

  belongs_to :uploader, class_name: 'User'
  belongs_to :library

  direct_upload :file

  validates :library, presence: true
  validates :uploader, presence: true
  validates :failed, inclusion: [ true, false ]
  validates :name, presence: true, uniqueness: { scope: [ :library_id, :size, :mime ] }
  validates :modified_at, presence: true
  validates :size, presence: true, numericality: { greater_than: 0 }
  validates :mime, presence: true, format: /\A\w+\/\w+\z/

  after_create :create_direct_upload_for_file, unless: :file?

  def process_file file
    if file == :not_found
      self.update_attributes!(failed: true)
    else
      self.update_attributes!(file: file)
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
