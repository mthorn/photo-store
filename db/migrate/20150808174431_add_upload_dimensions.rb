class AddUploadDimensions < ActiveRecord::Migration
  def change
    add_column :uploads, :width, :integer
    add_column :uploads, :height, :integer
  end
end
