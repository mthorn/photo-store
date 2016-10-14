class BackupDestroyJob < ApplicationJob

  queue_as :backup

  PREFIX = "#{::Rails.root}/private/"

  def perform(paths)
    paths.each do |path|
      key = path.sub(PREFIX, '')
      begin
        logger.info "Deleting backup #{key}"
        S3.delete_object(S3_BUCKET_NAME, key)
        logger.debug "#{key} deleted"
      rescue Excon::Error::NotFound
        logger.debug "#{key} not found"
      end
    end

    nil
  end

end
