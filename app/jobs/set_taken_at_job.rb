class SetTakenAtJob < ApplicationJob

  def perform
    Upload.where(taken_at: nil).where.not(metadata: nil).find_each do |upload|
      upload.save if upload.set_taken_at
    end
  end

end
