class AddUploadLocation < ActiveRecord::Migration
  def change
    add_column :uploads, :longitude, :decimal
    add_column :uploads, :latitude, :decimal
    add_column :uploads, :location, :string
    add_column :libraries, :tag_location, :boolean, default: true
  end
end
