class SetTimeTakenJob < ActiveJob::Base

  queue_as :default

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      Upload.where(taken_at: nil).where.not(metadata: nil).find_each do |upload|
        upload.save if upload.set_time_taken
      end
    end
  end

end
