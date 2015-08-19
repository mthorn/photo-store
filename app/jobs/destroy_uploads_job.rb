class DestroyUploadsJob < ActiveJob::Base

  queue_as :default

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      uploads = Upload.unscoped.where(state: 'destroy')
      locked_uploads = uploads.lock('FOR UPDATE NOWAIT')
      uploads.find_each do |upload|
        Upload.transaction do
          begin
            locked_uploads.find_by(id: upload.id).try(:destroy)
          rescue ActiveRecord::StatementInvalid
            raise if $!.message !~ /\APG::LockNotAvailable\b/
          end
        end
      end
    end
  end

end
