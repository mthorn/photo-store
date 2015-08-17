class AddSelection < ActiveRecord::Migration
  def change
    add_column :library_memberships, :selection, :text
  end
end
