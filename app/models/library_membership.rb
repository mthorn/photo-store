class LibraryMembership < ActiveRecord::Base

  belongs_to :user
  belongs_to :library
  belongs_to :role

  delegate :uploads, :can_upload?, :owner?, to: :role

  serialize :selection

  validates :user, presence: true
  validates :library, presence: true, uniqueness: { scope: :user_id }
  validates :role, presence: true

  validate :selection_array_of_integers
  def selection_array_of_integers
    return if self.selection.blank?

    if ! self.selection.is_a?(Array)
      self.errors.add(:selection, 'not an array')
    elsif self.selection.any? { |i| ! i.is_a?(Integer) }
      self.errors.add(:selection, 'contains invalid element(s)')
    end
  end

  validate :role_in_library
  def role_in_library
    return if self.role.blank? || self.library.blank?

    if self.role.library_id != self.library_id
      self.errors.add(:role_id, 'is not in the library')
    end
  end

  def update_selected params
    return true if self.selection.blank?

    uploads = self.library.uploads.where(id: self.selection)
    if (tags = params[:tags]).present?
      tags = tags.split(',').map { |tag| Tag.mangle(tag) }
      if (to_remove = tags.grep(/\A-/)).any?
        Tag.bulk_remove(self.library, self.selection, to_remove.map { |tag| tag[1..-1] })
      end
      if (to_add = tags.grep(/\A[^-]/)).any?
        Tag.bulk_add(self.library, self.selection, to_add)
      end
    end
  end

end
