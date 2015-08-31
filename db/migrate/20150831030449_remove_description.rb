class RemoveDescription < ActiveRecord::Migration
  def change
    revert { add_column :uploads, :description, :string }
  end
end
