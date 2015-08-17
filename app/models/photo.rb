class Photo < Upload

  mount_uploader :file, PhotoUploader

  before_validation :update_metadata, if: :file_changed?
  def update_metadata
    if self.file?
      return if self.width? && self.height?
      text = `identify -format '%w\n%h\n%[EXIF:*]' '#{self.file.path}'`.strip.split("\n")
      self.width = text.shift.to_i
      self.height = text.shift.to_i
      self.metadata = text.
        map { |l| l[5..-1].split('=', 2) }.
        each.with_object({}) { |(k, v), h| h[k] = v }

      if self.metadata['Orientation'].in?(%w( 6 8 ))
        self.width, self.height = self.height, self.width
      end
    else
      self.width = self.height = self.metadata = nil
    end
  end

end
