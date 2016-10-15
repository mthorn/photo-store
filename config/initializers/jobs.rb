heroku = ENV['DYNO'].present?

queue_adapter = ENV.fetch('QUEUE_ADAPTER') {
  if heroku
    require 'sucker_punch'
    'sucker_punch'
  else
    'delayed_job'
  end
}

Rails.logger.debug "Job queue adapter: #{queue_adapter}"
require queue_adapter
ActiveJob::Base.queue_adapter = queue_adapter.to_sym

case queue_adapter
when 'sucker_punch'
  ActiveJob::QueueAdapters::SuckerPunchAdapter::JobWrapper.workers((ENV['WORKER_COUNT'] || 2).to_i)

  RestartInterruptedUploadProcessingJob.perform_later
  CheckAwsTranscodesJob.perform_later

  ApplicationJob.perform_needs_new_connection = true

when 'delayed_job'
  Delayed::Worker.delay_jobs = Rails.env.production?
  Delayed::Worker.default_queue_name = 'default'
  Delayed::Worker.max_run_time = 10.minutes

  ApplicationJob.perform_needs_new_connection = false
end
