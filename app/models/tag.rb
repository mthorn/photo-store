class Tag < ActiveRecord::Base

  AUTO_TAG_KINDS = %w( aspect date camera location )

  belongs_to :upload

  validates :upload, presence: true
  validates :name, presence: true, format: /\A[a-z0-9][a-z0-9&-]*\z/, uniqueness: { scope: :upload_id }
  validates :kind, allow_nil: true, inclusion: AUTO_TAG_KINDS

  def self.mangle str
    str.to_s.downcase.gsub(/\s+/, '-').gsub(/[^a-z0-9&-]/, '')
  end

end
