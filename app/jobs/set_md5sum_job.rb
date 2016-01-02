class SetMd5sumJob < ActiveJob::Base

  queue_as :default

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      Upload.where(md5sum: nil).where.not(file: nil).find_each(batch_size: 10) do |upload|
        upload.update_attributes(md5sum: Digest::MD5.hexdigest(upload.file.file.read))
      end
    end
  end

end
