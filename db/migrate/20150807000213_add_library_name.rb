class AddLibraryName < ActiveRecord::Migration
  def change
    add_column :libraries, :name, :string
  end
end
