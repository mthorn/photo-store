class Role < ApplicationRecord

  belongs_to :library
  has_many :library_memberships

  serialize :restrict_tags

  validates :owner, inclusion: [ true, false ]
  validates :name, presence: true, uniqueness: { scope: :library_id }
  validates :can_upload, inclusion: [ true, false ]
  validates :restrict_tags, absence: { if: proc { owner? || can_upload? } }, array: { format: { with: /\A-?#{Tag::TAG_PATTERN}\z/ } }

  validate :prevent_change, if: :owner?, on: :update
  def prevent_change
    if self.changes.any?
      self.errors.add(:base, 'Can not change read only role')
    end
  end

  before_destroy :prevent_owner_destroy
  def prevent_owner_destroy
    throw(:abort) unless self.destroyable?
  end

  def destroyable?
    ! self.owner
  end

  def uploads
    rel = self.library.uploads

    if self.restrict_tags.present?
      if (negatives = self.restrict_tags.grep(/\A-/)).any?
        subquery = Tag.where(name: negatives.map { |tag| tag[1..-1] }).select(:upload_id)
        rel = rel.where("id NOT IN (#{subquery.to_sql})")
      end

      if (positives = self.restrict_tags - negatives).any?
        subquery = Tag.where(name: positives).select(:upload_id)
        rel = rel.where("id IN (#{subquery.to_sql})")
      end
    end

    rel
  end

end
