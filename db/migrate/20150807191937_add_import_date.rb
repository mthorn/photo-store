class AddImportDate < ActiveRecord::Migration
  def change
    add_column :uploads, :imported_at, :timestamp
  end
end
