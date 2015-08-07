class Library < ActiveRecord::Base

  has_many :uploads, dependent: :destroy
  belongs_to :owner, class_name: 'User'

  validates :name, presence: true

end
