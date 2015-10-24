class LibraryMembership < ActiveRecord::Base

  belongs_to :user
  belongs_to :library

  serialize :selection

  validate :selection_array_of_integers
  def selection_array_of_integers
    return if self.selection.blank?

    if ! self.selection.is_a?(Array)
      self.errors.add(:selection, 'not an array')
    elsif self.selection.any? { |i| ! i.is_a?(Integer) }
      self.errors.add(:selection, 'contains invalid element(s)')
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

  true
end
