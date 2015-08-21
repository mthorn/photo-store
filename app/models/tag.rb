class Tag < ActiveRecord::Base

  belongs_to :upload

  validates :upload, presence: true
  validates :name, presence: true, format: /\A[a-z0-9][a-z0-9&-]*\z/, uniqueness: { scope: :upload_id }

  def self.mangle str
    str.to_s.downcase.gsub(/\s+/, '-').gsub(/[^a-z0-9&-]/, '')
  end

end
