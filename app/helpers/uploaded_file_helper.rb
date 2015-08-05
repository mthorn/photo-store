module UploadedFileHelper
  def uploaded_file_url(model, version = nil)
    "/uploaded_files/#{model.id}" + (version ? "/#{version}" : "")
  end
end
