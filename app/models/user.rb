class User < ActiveRecord::Base

  devise :database_authenticatable, :lockable, :recoverable, :rememberable,
    :trackable, :validatable

  has_many :uploads, dependent: :destroy, foreign_key: :uploader_id
  has_many :libraries, through: :library_memberships, dependent: :destroy
  has_many :library_memberships, dependent: :destroy
  has_many :upload_buffers, dependent: :destroy
  belongs_to :default_library, class_name: 'Library'

  validates :name, presence: true
  validates :manual_deselect, inclusion: [ true, false ]
  validates :upload_block_size, presence: true, numericality: { greater_than: 0 }
  validates :default_library, presence: true

  validate :valid_time_zone, if: :time_zone_auto?
  def valid_time_zone
    old_zone = Time.zone
    begin
      Time.zone = self.time_zone_auto
    rescue ArgumentError
      self.errors.add(:time_zone_auto, 'is invalid')
    ensure
      Time.zone = old_zone
    end
  end

  def uploads
    Upload.joins(library: :library_memberships).where(library_memberships: { user_id: self.id })
  end

  def upload_block_size_mib
    (value = self.upload_block_size).presence && (value.to_f / (2 ** 20))
  end

  def upload_block_size_mib=(value)
    self.upload_block_size = value && (value.to_f * (2 ** 20))
  end

end
