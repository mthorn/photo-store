class Library < ApplicationRecord

  has_many :uploads, dependent: :destroy
  has_many :users, through: :library_memberships, dependent: :destroy
  has_many :library_memberships, dependent: :destroy
  has_many :roles, dependent: :destroy

  validates :name, presence: true
  validates :tag_new, format: /\A(?:#{Tag::TAG_PATTERN}(?:,#{Tag::TAG_PATTERN})*)?\z/

  after_create :create_owner_role
  def create_owner_role
    self.roles.create!(
      owner: true,
      name: 'owner',
      can_upload: true
    )
  end

  Tag::AUTO_TAG_KINDS.each do |kind|
    validates :"tag_#{kind}", inclusion: [ true, false ]
    after_save :"auto_tag_#{kind}", if: :"tag_#{kind}_changed?"
    define_method :"auto_tag_#{kind}" do
      if self.public_send(:"tag_#{kind}?")
        TagJob.perform_later(self, "auto_tag_#{kind}")
      else
        self.tags.where(kind: kind).delete_all
      end
    end
  end

  def tags
    Tag.joins(:upload).where(uploads: { library_id: self.id })
  end

  def tag_counts
    self.tags.group('tags.name').count
  end

  def deleted_count
    self.uploads.deleted.count
  end

  def owner_role
    self.roles.where(owner: true).first
  end

end
