class BackupDatabaseJob < ApplicationJob

  queue_as :backup

  PREFIX = "#{::Rails.root}/private/"

  def perform

    file = Tempfile.new('pgbackup', encoding: 'BINARY')

    begin
      config = Rails.configuration.database_configuration[Rails.env]
      if url = config['url']
        url = URI.parse(url)
        name = url.path.slice(1..-1)
        host = url.host
        port = url.port
        user = url.user
      else
        name, host, port, user = config.values_at('database', 'host', 'port', 'username')
      end

      system(
        'pg_dump', '--format=custom', '-w', '-h', (host || 'localhost'),
        '-p', (port || 5432).to_s, '-U', (user || 'postgres'), '-f', file.path,
        name
      )

      raise "Database dump failed" unless $? == 0

      backup_time = Time.current.strftime('%Y%m%d%H%M%S')
      backup_data = file.read
      backup_md5 = Digest::MD5.hexdigest(backup_data)
      backup_name = "#{Rails.env}_backup_#{backup_time}_#{backup_md5}.pgdump"

      existing = S3.directories.get(S3_BUCKET_NAME, prefix: "#{Rails.env}_backup_").files
      return if existing.any? { |f| f.etag == backup_md5 }

      S3.put_object(S3_BUCKET_NAME, backup_name, backup_data, {
        'Content-Type' => 'application/octet-stream',
        'x-amz-acl' => 'private'
      })
    ensure
      file.close
      file.unlink
    end

    nil
  end

end
