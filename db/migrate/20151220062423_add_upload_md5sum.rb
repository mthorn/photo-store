class AddUploadMd5sum < ActiveRecord::Migration
  def change
    add_column :uploads, :md5sum, :string
  end
end
