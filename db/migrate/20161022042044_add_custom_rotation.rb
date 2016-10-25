class AddCustomRotation < ActiveRecord::Migration[5.0]
  def change
    add_column :uploads, :rotate, :integer, default: 0
  end
end
