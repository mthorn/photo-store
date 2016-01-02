class CheckTranscodesJob < ActiveJob::Base

  queue_as :default

  def perform
    requeue = false
    ActiveRecord::Base.connection_pool.with_connection do
      videos = Video.where(state: 'process').where.not(external_job_id: nil)
      locked_videos = videos.lock('FOR UPDATE NOWAIT')
      videos.find_each do |video|
        Video.transaction do
          begin
            if video = locked_videos.find_by(id: video.id)
              video.check_transcode
              requeue ||= video.state == 'process'
            end
          rescue ActiveRecord::StatementInvalid
            raise if $!.message !~ /\APG::LockNotAvailable\b/
          end
        end
      end
    end
  ensure
    CheckTranscodesJob.set(wait: 5.seconds).perform_later if requeue
  end

end
