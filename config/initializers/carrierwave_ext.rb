module CarrierWave
  module MiniMagick
    def fix_exif_rotation
      manipulate! do |img|
        img.auto_orient
        img = yield(img) if block_given?
        img
      end
    end
  end

  def quality(percentage)
    manipulate! do |img|
      img.quality percentage
      img = yield(img) if block_given?
      img
    end
  end
end
