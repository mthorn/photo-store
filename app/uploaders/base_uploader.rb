class BaseUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  include Sprockets::Rails::Helper
  include UploaderExtension

  def store_dir
    path = "#{::Rails.root}/private/#{::Rails.env}_uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"

    if model.respond_to?(version_method = :"#{mounted_as}_version")
      path = "#{path}/#{model.public_send(version_method)}"
    end

    path
  end

end

