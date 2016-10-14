class SetMd5sumJob < ApplicationJob

  queue_as :default

  def perform
    Upload.where(md5sum: nil).where.not(file: nil).find_each(batch_size: 10) do |upload|
      upload.update_attributes(md5sum: Digest::MD5.hexdigest(upload.file.file.read))
    end
  end

end
