class Video < Upload

  mount_uploader :file, VideoUploader

  before_validation :update_metadata, if: :file_changed?
  def update_metadata
    if self.file?
      return if self.width? && self.height?

      probe_text = `ffprobe -show_format -show_streams #{self.file.path} 2>/dev/null`
      metadata = probe_text.
        scan(/(?<=\[FORMAT\]).*?(?=\[\/FORMAT\])/m).
        join('').
        split(/\r?\n/).
        grep(/\ATAG:/).
        map { |l| l.sub(/\ATAG:/, '').split('=', 2) }.
        each.
        with_object({}) { |(k, v), h| h[k] = v }
      metadata['streams'] = streams = probe_text.
        scan(/(?<=\[STREAM\]).*?(?=\[\/STREAM\])/m).
        map { |s| s.
          strip.
          split(/\r?\n/).
          map { |l| l.split('=') }.
          each.
          with_object({}) { |(k, v), h| h[k] = v }
        }

      self.metadata = metadata

      if video = streams.find { |h| h['codec_type'] == 'video' }
        self.width = video['width'].to_i
        self.height = video['height'].to_i
        if video['TAG:rotate'].in?(%w( 90 270 ))
          self.width, self.height = self.height, self.width
        end
      end

      self.set_time_taken

    else
      self.width = self.height = self.metadata = self.taken_at = nil
    end
  end

  def set_time_taken
    if self.metadata?
      self.taken_at = (date = self.metadata['date']) &&
        (Time.zone.local(*date.scan(/\d+/)) rescue nil) ||
        self.modified_at || self.imported_at || self.created_at
    end
  end

end
