class ProcessUploadJob < ApplicationJob

  def perform(model, field)
    model.fetch_and_process(field.to_sym)
  end

end
