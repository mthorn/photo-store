class AddTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.belongs_to :upload
      t.string :name
      t.timestamps
    end

    add_index :tags, [ :upload_id, :name ], unique: true
  end
end
