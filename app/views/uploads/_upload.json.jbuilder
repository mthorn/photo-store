json.(upload, :id, :library_id, :type, :state, :mime, :modified_at, :name,
      :size, :file_posts, :width, :height, :taken_at, :location, :imported_at,
      :deleted_at)
json.tags upload.tags.map(&:name)
json.partial!(upload.class.name.underscore, upload: upload) if upload.class != Upload
