class RecreateVersionsJob < ApplicationJob

  def perform(upload_id)
    Upload.find_by(id: upload_id)&.recreate_versions!
  end

end
