Rails.application.configure do
  config.active_job.queue_adapter = :sucker_punch
end

if defined? Rails::Server
  RestartInterruptedUploadProcessingJob.perform_later
end
