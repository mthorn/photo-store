class LibraryMembership < ActiveRecord::Base

  belongs_to :user
  belongs_to :library

  serialize :selection

  validates :selection, allow_nil: true, array: { numericality: { only_integer: true } }

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
