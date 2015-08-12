class PhotoUploader < BaseUploader

  def extension_white_list
    %w( jpg jpeg gif png )
  end

  version :gallery do
    process :fix_exif_rotation
    process resize_to_fit: [ 256, 256 ]
    process resize_and_pad: [ 256, 256 ]
  end

  version :large do
    process :fix_exif_rotation
    process resize_to_fit: [ 1280, 960 ]
  end

end
