class User < ActiveRecord::Base

  devise :database_authenticatable, :lockable, :recoverable, :rememberable,
    :trackable, :validatable

  has_many :uploads, dependent: :destroy, foreign_key: :uploader_id
  has_one :library, foreign_key: :owner_id
  has_many :upload_buffers, dependent: :destroy

  validates :name, presence: true

end
