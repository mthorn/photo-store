class UploadBuffer < ActiveRecord::Base

  belongs_to :user

  mount_uploader :data, AnyUploader

  validates :user, presence: true
  validates :key, presence: true

  validate :validate_data_size
  def validate_data_size
    if self.size? && self.data? && (size = self.data.size) && size != self.size
      self.errors.add(:data, "is not the expected size (#{self.size})")
    end
  end

end
