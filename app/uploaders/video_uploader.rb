class VideoUploader < BaseUploader

  MIME_OVERRIDES = {
    'video/quicktime' => 'video/mp4',
    'video/x-m4v' => 'video/mp4'
  }

  version :large do
    process extract_frame: 0.1
    process resize_to_fit: [ 1280, 960 ]
    def full_filename(file)
      file ||= self.model.public_send(self.mounted_as).file
      file + '.large.jpg'
    end
  end

  version :gallery, from_version: :large do
    process convert: :jpg
    process resize_to_fit: [ 256, 256 ]
    process resize_and_pad: [ 256, 256 ]
    def full_filename(file)
      file ||= self.model.public_send(self.mounted_as).file
      file + '.gallery.jpg'
    end
  end

  version :transcoded do
    process placeholder: :mp4
  end

  def extension_white_list
    %w( mp4 m4v mov )
  end

  def fog_attributes
    mime = self.model.mime
    { 'Content-Type' => self.content_type }
  end

  def content_type
    mime = super
    MIME_OVERRIDES[mime] || mime
  end

end
