json.(upload, :id, :type, :failed, :mime, :modified_at, :name, :size,
      :description, :file_s3_target, :file_s3_post_data)
json.partial!(upload.class.name.underscore, upload: upload) if upload.class != Upload
