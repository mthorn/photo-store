json.video_url(uploaded_file_url(upload, TRANSCODE_METHOD ? :transcoded : nil))
json.large_url uploaded_file_url(upload, :large)
json.gallery_url uploaded_file_url(upload, :gallery)
