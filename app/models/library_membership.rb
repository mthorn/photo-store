class LibraryMembership < ActiveRecord::Base

  belongs_to :user
  belongs_to :library

  serialize :selection

  validates :selection, allow_nil: true, array: { numericality: { only_integer: true } }

end
