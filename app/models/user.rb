class User < ActiveRecord::Base

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  has_many :uploads, dependent: :destroy, foreign_key: :uploader_id
  has_one :library, foreign_key: :owner_id

  validates :name, presence: true

end
