class Library < ActiveRecord::Base

  has_many :uploads, dependent: :destroy
  has_many :users, through: :library_memberships, dependent: :destroy
  has_many :library_memberships, dependent: :destroy

  validates :name, presence: true
  validates :tag_new, format: /\A(?:[a-z0-9][a-z0-9&-]* *)*\z/
  validates :tag_aspect, inclusion: [ true, false ]
  validates :tag_date, inclusion: [ true, false ]
  validates :tag_camera, :boolean, default: false

  after_save :auto_tag_aspect, if: :tag_aspect_changed?
  def auto_tag_aspect
    TagJob.perform_later(self, 'auto_tag_aspect') if self.tag_aspect?
  end

  after_save :auto_tag_date, if: :tag_date_changed?
  def auto_tag_date
    TagJob.perform_later(self, 'auto_tag_date') if self.tag_date?
  end

  after_save :auto_tag_camera, if: :tag_camera_changed?
  def auto_tag_camera
    TagJob.perform_later(self, 'auto_tag_camera') if self.tag_camera?
  end

  def deleted_count
    self.uploads.deleted.count
  end

end
