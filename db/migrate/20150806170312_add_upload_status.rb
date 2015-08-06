class AddUploadStatus < ActiveRecord::Migration
  def change
    add_column :uploads, :state, :string
    revert { add_column :uploads, :failed, :boolean, default: false }
  end
end
