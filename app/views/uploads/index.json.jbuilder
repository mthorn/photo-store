json.count @count
json.items @uploads do |upload|
  json.partial! 'upload', upload: upload
end
