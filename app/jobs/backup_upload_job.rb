class BackupUploadJob < ApplicationJob

  queue_as :backup

  PREFIX = "#{::Rails.root}/private/"

  def perform(upload_id, *versions)
    upload = Upload.find(upload_id)
    file = upload.file

    versions.flatten.each do |version|
      uploader = version == 'original' ? file : file.versions[version.to_sym]
      next unless File.file?(path = uploader.path)

      size = File.size(path)
      key = path.sub(PREFIX, '')
      begin
        head = S3.head_object(S3_BUCKET_NAME, key)
        if (existing_size = head.headers['Content-Length'].to_i) == size
          logger.debug "#{key} backup present"
          next
        else
          logger.debug "#{key} backup present but incomplete (#{existing_size})"
        end
      rescue Excon::Error::NotFound
        logger.debug "#{key} not found"
      end

      logger.info "Backing up #{key} to S3, #{size} bytes"
      S3.put_object(S3_BUCKET_NAME, key, File.read(path, encoding: 'BINARY'), {
        'Content-Type' => uploader.content_type,
        'x-amz-acl' => 'private'
      })
    end

    nil
  end

end
