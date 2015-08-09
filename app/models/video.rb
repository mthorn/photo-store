class Video < Upload

  mount_uploader :file, VideoUploader

  before_validation :update_metadata, if: :file_changed?
  def update_metadata
    if self.file?
      return if self.width? && self.height?

      streams = `ffprobe -show_streams #{self.file.path} 2>/dev/null`.
        scan(/(?<=\[STREAM\]).*?(?=\[\/STREAM\])/m).
        map { |s| s.
          strip.
          split(/\r?\n/).
          map { |l| l.split('=') }.
          each.
          with_object({}) { |(k, v), h| h[k] = v }
        }

      self.metadata = streams
      if video = streams.find { |h| h['codec_type'] == 'video' }
        self.width = video['width'].to_i
        self.height = video['height'].to_i
      end

    else
      self.width = self.height = self.metadata = nil
    end
  end

end
