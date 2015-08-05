class AddUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :type
      t.references :uploader
      t.timestamps

      t.string :file
      t.boolean :failed, default: false

      t.timestamp :modified_at
      t.string :name
      t.integer :size
      t.string :mime
      t.text :description
    end
  end
end
