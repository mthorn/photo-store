Rails.application.configure do
  config.active_job.queue_adapter = :sucker_punch
end

ActiveJob::QueueAdapters::SuckerPunchAdapter::JobWrapper.workers((ENV['WORKER_COUNT'] || 2).to_i)

if defined? Rails::Server
  RestartInterruptedUploadProcessingJob.perform_later
end

class ActiveJob::QueueAdapters::SuckerPunchAdapter
  def self.enqueue_at(job, timestamp)
    delay = timestamp - Time.current.to_f
    JobWrapper.new.async.later delay, job.serialize
  end

  class JobWrapper
    def later(sec, data)
      after(sec) { perform(data) }
    end
  end
end
