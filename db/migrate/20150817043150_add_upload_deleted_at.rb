class AddUploadDeletedAt < ActiveRecord::Migration
  def change
    add_column :uploads, :deleted_at, :timestamp
  end
end
