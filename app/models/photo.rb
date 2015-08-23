class Photo < Upload

  mount_uploader :file, PhotoUploader

  before_validation :update_metadata, if: :file_changed?
  def update_metadata
    if self.file?
      text = `identify -format '%w\n%h\n%[EXIF:*]' '#{self.file.path}'`.strip.split("\n")
      self.width = text.shift.to_i
      self.height = text.shift.to_i
      self.metadata = text.
        map { |l| l[5..-1].split('=', 2) }.
        each.with_object({}) { |(k, v), h| h[k] = v }

      if self.metadata['Orientation'].in?(%w( 6 8 ))
        self.width, self.height = self.height, self.width
      end

      self.set_taken_at
      self.set_coordinates
    else
      self.width = self.height = self.metadata = self.taken_at =
        self.latitude = self.longitude = nil
    end
  end

  after_save :auto_tag_camera, if: -> { self.metadata_changed? && self.library_tag_camera }
  def auto_tag_camera
    if camera = self.metadata.try(:[], 'Model')
      self.tags.create(name: Tag.mangle(camera))
    end
  end

  def set_taken_at
    if self.metadata?
      self.taken_at = (date = self.metadata['DateTime']) &&
        (Time.zone.local(*date.scan(/\d+/)) rescue nil) ||
        self.modified_at || self.imported_at || self.created_at
    end
  end

  def set_coordinates
    if self.metadata?
      self.latitude, self.longitude = %w( GPSLatitude GPSLongitude ).map do |key|
        if (dms = self.metadata[key]).present? && (dir = self.metadata[key + 'Ref']).present?
          d, m, s = dms.split(/, */).map { |r| Rational(*r.split('/')) }
          (d + (m / 60) + (s / 3600)).to_f * (dir.in?(%w( S W )) ? -1 : 1)
        else
          nil
        end
      end
    end
  end

end
