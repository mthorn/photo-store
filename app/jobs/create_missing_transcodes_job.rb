class CreateMissingTranscodesJob < ApplicationJob

  queue_as :default

  def perform
    Video.
      where(external_job_id: nil, state: 'ready').
      find_each(&:create_transcode_job)
    CheckTranscodesJob.set(wait: 5.seconds).perform_later
  end

end
