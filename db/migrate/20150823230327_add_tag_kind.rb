class AddTagKind < ActiveRecord::Migration
  def change
    add_column :tags, :kind, :string
  end
end
