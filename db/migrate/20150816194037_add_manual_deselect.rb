class AddManualDeselect < ActiveRecord::Migration
  def change
    add_column :users, :manual_deselect, :boolean, default: false
  end
end
