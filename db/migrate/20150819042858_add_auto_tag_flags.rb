class AddAutoTagFlags < ActiveRecord::Migration
  def change
    add_column :libraries, :tag_new, :string, default: 'new'
    add_column :libraries, :tag_aspect, :boolean, default: true
    add_column :libraries, :tag_date, :boolean, default: true
    add_column :libraries, :tag_camera, :boolean, default: false
  end
end
