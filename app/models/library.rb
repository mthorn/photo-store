class Library < ActiveRecord::Base

  has_many :uploads, dependent: :destroy
  has_many :users, through: :library_memberships, dependent: :destroy
  has_many :library_memberships, dependent: :destroy

  validates :name, presence: true

  def deleted_count
    self.uploads.deleted.count
  end

end
