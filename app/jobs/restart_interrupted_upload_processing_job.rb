class RestartInterruptedUploadProcessingJob < ApplicationJob

  queue_as :default

  def perform
    count = 0
    Upload.where(state: 'process', file: nil).find_each do |upload|
      count += 1
      ProcessUploadJob.perform_later(upload, 'file')
    end
    if count.nonzero?
      logger.info "Restarted #{count} upload processing jobs"
    end
  end

end
