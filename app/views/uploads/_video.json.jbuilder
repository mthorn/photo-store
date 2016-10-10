json.video_url(AWS_TRANSCODER ? uploaded_file_url(upload, :transcoded) : uploaded_file_url(upload))
json.large_url uploaded_file_url(upload, :large)
json.gallery_url uploaded_file_url(upload, :gallery)
