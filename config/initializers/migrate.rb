if ENV['DYNO'] !~ /\Arun\./ && ENV['AUTO_MIGRATE'] != 'false'
  ActiveRecord::Base.transaction do
    conn = ActiveRecord::Base.connection
    conn.execute("LOCK TABLE schema_migrations IN ACCESS EXCLUSIVE MODE")
    Rails.logger.debug('Checking migrations')
    if ActiveRecord::Migrator.needs_migration?(conn)
      ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)
    else
      Rails.logger.debug('No migrations to apply!')
    end
  end
end
