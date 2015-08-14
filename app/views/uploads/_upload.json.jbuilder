json.(upload, :id, :library_id, :type, :state, :mime, :modified_at, :name,
      :size, :description, :file_post_url, :file_post_data, :width, :height)
json.partial!(upload.class.name.underscore, upload: upload) if upload.class != Upload
