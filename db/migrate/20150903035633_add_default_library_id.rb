class AddDefaultLibraryId < ActiveRecord::Migration
  def change
    add_column :users, :default_library_id, :integer

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          WITH defaults AS (
            SELECT MIN(library_id) AS min_library_id, user_id
            FROM library_memberships
            GROUP BY user_id
          )
          UPDATE users
          SET default_library_id = defaults.min_library_id
          FROM defaults
          WHERE users.id = defaults.user_id
        SQL
      end
    end
  end
end
