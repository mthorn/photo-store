class AddLibraries < ActiveRecord::Migration
  def change
    create_table :libraries do |t|
      t.belongs_to :owner
    end

    add_column :uploads, :library_id, :integer
  end
end
