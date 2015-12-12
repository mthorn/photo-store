class AddRoles < ActiveRecord::Migration
  def change
    add_column :library_memberships, :role_id, :integer

    create_table :roles do |t|
      t.references :library

      t.boolean :owner, default: false
      t.string :name
      t.boolean :can_upload, default: false
      t.text :restrict_tags
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          INSERT INTO roles (library_id, name, owner, can_upload)
          SELECT id, 'owner', 't', 't'
          FROM libraries
        SQL

        execute <<-SQL.squish
          UPDATE library_memberships
          SET role_id = roles.id
          FROM roles
          WHERE library_memberships.library_id = roles.library_id
        SQL
      end
    end
  end
end
