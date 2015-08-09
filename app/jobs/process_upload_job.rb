class ProcessUploadJob < ActiveJob::Base

  queue_as :default

  def perform(model, field)
    ActiveRecord::Base.connection_pool.with_connection do
      model.fetch_and_process(field.to_sym)
    end
  end

end
