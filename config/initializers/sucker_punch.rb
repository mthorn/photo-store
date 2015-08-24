Rails.application.configure do
  config.active_job.queue_adapter = :sucker_punch
end

ActiveJob::QueueAdapters::SuckerPunchAdapter::JobWrapper.workers((ENV['WORKER_COUNT'] || 2).to_i)

if defined? Rails::Server
  RestartInterruptedUploadProcessingJob.perform_later
end
