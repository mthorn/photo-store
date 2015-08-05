class Photo < Upload

  mount_uploader :file, PhotoUploader

end
