class Video < Upload

  mount_uploader :file, VideoUploader

  before_validation :update_metadata, if: :file_changed?
  def update_metadata
    if self.file?
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

      self.set_taken_at
      self.set_coordinates
    else
      self.width = self.height = self.metadata = self.taken_at =
        self.latitude = self.longitude = nil
    end
  end

  after_save :auto_tag_camera, if: -> { self.metadata_changed? && self.library_tag_camera }
  def auto_tag_camera
    if camera = self.metadata.try(:[], 'model')
      self.tags.create(name: Tag.mangle(camera), kind: 'camera')
    end
  end

  def set_taken_at
    if self.metadata?
      self.taken_at = (date = self.metadata['date']) &&
        (Time.zone.local(*date.scan(/\d+/)) rescue nil) ||
        self.modified_at || self.imported_at || self.created_at
    end
  end

  def set_coordinates
    if self.metadata? && (location = self.metadata['location']).present?
      self.latitude, self.longitude = location.scan(/[+-]\d+\.\d+/).map(&:to_f)
    end
  end

  def process_file_data(blocks)
    if AWS_TRANSCODER
      super(blocks, 'process')
      if self.state == 'process'
        self.create_transcode_job
        CheckTranscodesJob.set(wait: 5.seconds).perform_later
      end
    else
      super
    end
    nil
  end

  def check_transcode
    job = AWS_TRANSCODER.read_job(id: self.external_job_id)
    case job.job.status
      when 'Complete'
        logger.debug "Transcode #{self.external_job_id} complete"
        self.update_attributes(state: 'ready')
      when 'Error'
        logger.debug "Transcode #{self.external_job_id} error"
        self.update_attributes(state: 'fail')
    end
  end

  def create_transcode_job
    output = self.file.transcoded.path
    output_folder = output.sub(/[^\/]*\z/, '')
    output_file_name = File.basename(output)

    begin
      S3.delete_object(S3_BUCKET_NAME, output)
    rescue Excon::Errors::NotFound
    end

    job_id = AWS_TRANSCODER.create_job(
      pipeline_id: ELASTIC_TRANSCODER_PIPELINE_ID,
      input: {
        key: self.file.path
      },
      output_key_prefix: output_folder,
      outputs: [
        {
          key: output_file_name,
          preset_id: ELASTIC_TRANSCODER_PRESET_ID
        }
      ]
    )[:job][:id]

    logger.debug "Created transcode job #{job_id}"
    self.update_columns(
      external_job_id: job_id,
      state: 'process'
    )
  end

end
