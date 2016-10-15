class BaseUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  include Sprockets::Rails::Helper

  def store_dir
    path = "#{::Rails.root}/private/#{::Rails.env}_uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"

    if model.respond_to?(version_method = :"#{mounted_as}_version")
      path = "#{path}/#{model.public_send(version_method)}"
    end

    path
  end

  def fix_exif_rotation
    manipulate! do |img|
      img.auto_orient
      img = yield(img) if block_given?
      img
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

