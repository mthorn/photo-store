class AddS3BackupFlag < ActiveRecord::Migration
  def change
    add_column :uploads, :s3_backup, :boolean, default: false
  end
end
