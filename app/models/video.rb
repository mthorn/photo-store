class Video < Upload

  mount_uploader :file, VideoUploader

end
