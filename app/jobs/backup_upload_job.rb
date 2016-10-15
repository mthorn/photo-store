class BackupUploadJob < ApplicationJob

  queue_as :backup

  PREFIX = "#{::Rails.root}/private/"

  def perform(upload_id, *versions)
    upload = Upload.find_by(id: upload_id)
    return unless upload

    file = upload.file

    versions.flatten.each do |version|
      uploader = version == 'original' ? file : file.versions[version.to_sym]
      next unless File.file?(path = uploader.path)

      size = File.size(path)
      key = path.sub(PREFIX, '')
      data = proc { File.read(path, encoding: 'BINARY') }
      begin
        head = S3.head_object(S3_BUCKET_NAME, key)
        if (existing_size = head.headers['Content-Length'].to_i) == size &&
            (existing_md5sum = head.headers['ETag'].scan(/\w+/).first) == Digest::MD5.hexdigest(data[])
          logger.debug "#{key} backup present"
          next
        else
          logger.debug "#{key} backup present but outdated (#{existing_size}, #{existing_md5sum})"
        end
      rescue Excon::Error::NotFound
        logger.debug "#{key} not found"
      end

      logger.info "Backing up #{key} to S3, #{size} bytes"
      S3.put_object(S3_BUCKET_NAME, key, data[], {
        'Content-Type' => uploader.content_type,
        'x-amz-acl' => 'private'
      })
    end

    nil
  end

end
