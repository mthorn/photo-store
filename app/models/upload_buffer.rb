class UploadBuffer < ActiveRecord::Base

  belongs_to :user

  validates :user, presence: true
  validates :key, presence: true

  mount_uploader :data, AnyUploader

end
