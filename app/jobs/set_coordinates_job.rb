class SetCoordinatesJob < ActiveJob::Base

  queue_as :default

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      Upload.where(latitude: nil, longitude: nil).where.not(metadata: nil).find_each do |upload|
        upload.save if upload.set_coordinates
      end
    end
  end

end
