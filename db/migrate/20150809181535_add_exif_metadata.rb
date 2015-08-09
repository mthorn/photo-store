class AddExifMetadata < ActiveRecord::Migration
  def change
    add_column :uploads, :metadata, :text
  end
end
