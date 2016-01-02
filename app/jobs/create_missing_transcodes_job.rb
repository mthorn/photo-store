class CreateMissingTranscodesJob < ActiveJob::Base

  queue_as :default

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      Video.
        where(external_job_id: nil, state: 'ready').
        find_each(&:create_transcode_job)
      CheckTranscodesJob.set(wait: 5.seconds).perform_later
    end
  end

end
