class AddTakenAt < ActiveRecord::Migration
  def change
    add_column :uploads, :taken_at, :timestamp
  end
end
