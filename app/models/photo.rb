class Photo < Upload

  mount_uploader :file, PhotoUploader

  before_validation :calculate_dimensions, if: :file_changed?
  def calculate_dimensions
    if self.file?
      return if self.width? && self.height?
      self.width, self.height = `identify -format '%w %h' '#{self.file.path}'`.strip.split(' ')
    else
      self.width = self.height = nil
    end
  end

end
