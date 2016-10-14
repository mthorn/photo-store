class Tag < ApplicationRecord

  AUTO_TAG_KINDS = %w( aspect date camera location )
  TAG_PATTERN = '[a-z0-9][a-z0-9&-]*'

  belongs_to :upload

  validates :upload, presence: true
  validates :name, presence: true, format: /\A#{TAG_PATTERN}\z/, uniqueness: { scope: :upload_id }
  validates :kind, allow_nil: true, inclusion: AUTO_TAG_KINDS

  def self.mangle str
    str.to_s.downcase.gsub(/\s+/, '-').gsub(/[^a-z0-9&-]/, '')
  end

  def self.in_library(library)
    self.where("upload_id IN (#{library.uploads.select(:id).to_sql})")
  end

  def self.bulk_remove(library, upload_ids, tags)
    self.in_library(library).where(upload_id: upload_ids, name: tags).delete_all
  end

  def self.bulk_add(library, upload_ids, tags)
    tags = tags.grep(/\A#{TAG_PATTERN}\z/)
    Tag.connection.execute <<-SQL.squish
      INSERT INTO tags (upload_id, name, created_at, updated_at)
      SELECT new_tags.column1, new_tags.column2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM (
        VALUES #{
          upload_ids.map { |upload_id|
            tags.map { |tag|
              "(#{upload_id},#{Tag.sanitize(tag)})"
            }
          }.flatten.join(',')
        }
      ) new_tags
      WHERE new_tags.column1 IN (#{library.uploads.select(:id).to_sql})
      AND (new_tags.column1, new_tags.column2) NOT IN (
        SELECT upload_id, name
        FROM tags
        WHERE upload_id IN (#{upload_ids.join(',')})
      )
    SQL
  end

end
