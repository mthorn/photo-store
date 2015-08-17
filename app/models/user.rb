class User < ActiveRecord::Base

  devise :database_authenticatable, :lockable, :recoverable, :rememberable,
    :trackable, :validatable

  has_many :uploads, dependent: :destroy, foreign_key: :uploader_id
  has_many :libraries, through: :library_memberships, dependent: :destroy
  has_many :library_memberships, dependent: :destroy
  has_many :upload_buffers, dependent: :destroy

  validates :name, presence: true
  validates :manual_deselect, inclusion: [ true, false ]

  def uploads
    Upload.joins(library: :library_memberships).where(library_memberships: { user_id: self.id })
  end

end
