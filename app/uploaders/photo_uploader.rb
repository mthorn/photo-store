class PhotoUploader < BaseUploader

  def extension_white_list
    %w( jpg jpeg gif png )
  end

  version :thumb do
    process resize_to_fit: [ 128, 96 ]
    process resize_and_pad: [ 128, 96 ]
  end

  version :large do
    process resize_to_fit: [ 1280, 960 ]
  end

end
