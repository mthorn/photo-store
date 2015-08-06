class CreateUploadBuffers < ActiveRecord::Migration
  def change
    create_table :upload_buffers do |t|
      t.belongs_to :user
      t.string :key
      t.string :data
    end

    add_index :upload_buffers, :key, unique: true
  end
end
