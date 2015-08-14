class MultipleLibrariesPerUser < ActiveRecord::Migration
  def change
    create_table :library_memberships do |t|
      t.belongs_to :user
      t.belongs_to :library
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          INSERT INTO library_memberships (user_id, library_id, created_at, updated_at)
          SELECT owner_id, id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
          FROM libraries
        SQL
      end
      dir.down do
        execute <<-SQL.squish
          UPDATE libraries
          SET owner_id = library_memberships.user_id
          FROM library_memberships
          WHERE libraries.id = library_memberships.library_id
        SQL
      end
    end

    revert { add_column :libraries, :owner_id, :integer }
  end
end
