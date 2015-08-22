class AddUserTimeZone < ActiveRecord::Migration
  def change
    add_column :users, :time_zone_auto, :string
  end
end
