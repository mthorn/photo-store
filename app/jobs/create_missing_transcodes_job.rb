class CreateMissingTranscodesJob < ApplicationJob

  queue_as :default

  def perform
    return unless TRANSCODE_METHOD == :aws
    Video.
      where(external_job_id: nil, state: 'ready').
      find_each(&:create_aws_transcode_job)
    CheckAwsTranscodesJob.set(wait: 5.seconds).perform_later
  end

end
