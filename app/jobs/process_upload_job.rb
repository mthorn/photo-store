class ProcessUploadJob < ApplicationJob

  queue_as :default

  def perform(model, field)
    model.fetch_and_process(field.to_sym)
  end

end
