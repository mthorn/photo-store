class DestroyUploadsJob < ApplicationJob

  def perform
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
