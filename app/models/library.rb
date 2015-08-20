class Library < ActiveRecord::Base

  has_many :uploads, dependent: :destroy
  has_many :users, through: :library_memberships, dependent: :destroy
  has_many :library_memberships, dependent: :destroy

  validates :name, presence: true
  validates :tag_new, format: /\A(?:[a-z0-9][a-z0-9&-]* *)*\z/
  validates :tag_aspect, inclusion: [ true, false ]
  validates :tag_date, inclusion: [ true, false ]
  validates :tag_camera, :boolean, default: false

  def deleted_count
    self.uploads.deleted.count
  end

end
