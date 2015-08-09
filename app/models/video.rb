class Video < Upload

  mount_uploader :file, VideoUploader

  before_validation :calculate_dimensions, if: :file_changed?
  def calculate_dimensions
    if self.file?
      return if self.width? && self.height?

      video = `ffprobe -show_streams #{self.file.path} 2>/dev/null`.
        scan(/(?<=\[STREAM\]).*?(?=\[\/STREAM\])/m).
        map { |s| s.
          strip.
          split(/\r?\n/).
          map { |l| l.split('=') }.
          each.
          with_object({}) { |(k, v), h| h[k] = v }
        }.
        find { |h| h['codec_type'] == 'video' }

      if video
        self.width = video['width'].to_i
        self.height = video['height'].to_i
      end

    else
      self.width = self.height = nil
    end
  end

end
