class VideoUploader < BaseUploader

  MIME_OVERRIDES = {
    'video/quicktime' => 'video/mp4',
    'video/x-m4v' => 'video/mp4'
  }

  def extension_white_list
    %w( mp4 m4v mov )
  end

  def fog_attributes
    mime = self.model.mime
    { 'Content-Type' => (MIME_OVERRIDES[mime] || mime) }
  end

end
