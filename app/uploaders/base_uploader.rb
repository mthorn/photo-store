class BaseUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  include Sprockets::Rails::Helper

  def store_dir
    path = [
      "#{::Rails.env}_uploads",
      model.class.to_s.underscore,
      mounted_as,
      model.id
    ]

    if model.respond_to?(version_method = :"#{mounted_as}_version")
      path << model.public_send(version_method)
    end

    path.join('/')
  end

end

