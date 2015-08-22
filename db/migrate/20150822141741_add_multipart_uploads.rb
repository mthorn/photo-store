class AddMultipartUploads < ActiveRecord::Migration
  def change
    add_column :users, :upload_block_size, :integer, default: 5 * (2 ** 20)
    add_column :uploads, :block_size, :integer
    add_column :upload_buffers, :size, :integer

    reversible do |dir|
      dir.up do
        execute "UPDATE uploads SET block_size = size"
      end
    end
  end
end
