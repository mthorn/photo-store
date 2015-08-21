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

      self.set_time_taken
    else
      self.width = self.height = self.metadata = self.taken_at = nil
    end
  end

  after_save :auto_tag_date, if: -> { taken_at_changed? && taken_at? && self.library_tag_date }
  def auto_tag_date
    self.tags.create(name: self.taken_at.year.to_s)
    self.tags.create(name: self.taken_at.strftime('%B').downcase) # month
  end

  after_save :auto_tag_camera, if: -> { metadata_changed? && metadata? && self.library_tag_camera }
  def auto_tag_camera
    if camera = self.metadata['Model']
      self.tags.create(name: Tag.mangle(camera))
    end
  end

  def set_time_taken
    if self.metadata?
      self.taken_at = (date = self.metadata['DateTime']) &&
        (Time.zone.local(*date.scan(/\d+/)) rescue nil) ||
        self.modified_at || self.imported_at || self.created_at
    end
  end

end
