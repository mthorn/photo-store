class VideoUploader < BaseUploader

  def extension_white_list
    %w( mp4 m4v mov )
  end

end
