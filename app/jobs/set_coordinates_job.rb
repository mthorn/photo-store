class SetCoordinatesJob < ApplicationJob

  def perform
    Upload.where(latitude: nil, longitude: nil).where.not(metadata: nil).find_each do |upload|
      upload.save if upload.set_coordinates
    end
  end

end
