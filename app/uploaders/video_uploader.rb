class VideoUploader < BaseUploader

  MIME_OVERRIDES = {
    'video/quicktime' => 'video/mp4',
    'video/x-m4v' => 'video/mp4'
  }

  version :large do
    process extract_frame: 0.1
    process resize_to_fit: [ 1280, 960 ]
    def full_filename(file)
      file ||= self.model.public_send(self.mounted_as).file
      file + '.large.jpg'
    end
  end

  version :gallery, from_version: :large do
    process convert: :jpg
    process resize_to_fit: [ 256, 256 ]
    process resize_and_pad: [ 256, 256 ]
    def full_filename(file)
      file ||= self.model.public_send(self.mounted_as).file
      file + '.gallery.jpg'
    end
  end

  if TRANSCODE_METHOD
    version :transcoded do
      case TRANSCODE_METHOD
      when :aws
        process placeholder: :mp4
      when :ffmpeg
        process transcode: [ 1280, 960 ]
      end
    end
  end

  def extension_white_list
    %w( mp4 m4v mov )
  end

  def fog_attributes
    mime = self.model.mime
    { 'Content-Type' => self.content_type }
  end

  def content_type
    mime = super
    MIME_OVERRIDES[mime] || mime
  end

  def extract_frame(fraction)
    frame = Tempfile.new(%w( frame .jpg ), encoding: 'BINARY')
    begin
      duration = probe('duration')&.to_f || 0
      cmd = FFMPEG_EXTRACT_FRAME.
        sub('INPUT', current_path).
        sub('TIME', (duration * fraction).to_s).
        sub('OUTPUT', frame.path)
      Rails.logger.info cmd
      system(cmd)
      raise 'Error extracting frame' unless $? == 0

      if FFMPEG_FIX_EXTRACTED_FRAME_ROTATION
        rotate = probe('TAG:rotate')&.to_i
        if rotate && rotate != 0
          system('mogrify', '-rotate', rotate, frame.path)
        end
      end

      # avoid frame.read() - seems to cache old version
      File.write(current_path, File.read(frame.path, encoding: 'BINARY'), encoding: 'BINARY')
      @format = :jpg
    ensure
      frame.close
      frame.unlink
    end
  end

  def placeholder(format)
    File.write(current_path, '')
    @format = format
  end

  def transcode(max_width, max_height)
    width = probe('width').to_f
    height = probe('height').to_f
    rotate = probe('TAG:rotate')&.to_i
    width, height = height, width if rotate.in?([ 90, 270 ])

    if width > max_width || height > max_height
      aspect = width / height
      if aspect < (max_width.to_f / max_height.to_f)
        height = max_height
        width = height * aspect
      else
        width = max_width
        height = width / aspect
      end
    end

    transcoded = Tempfile.new(%w( transcode .mp4 ), encoding: 'BINARY')
    begin
      cmd = FFMPEG_TRANSCODE.
        sub('INPUT', current_path).
        sub('SCALE', "#{width.to_i}x#{height.to_i}").
        sub('OUTPUT', transcoded.path)
      Rails.logger.info cmd
      system(cmd)
      raise 'Error transcoding video' unless $? == 0

      # avoid transcoded.read() - seems to cache old version
      File.write(current_path, File.read(transcoded.path, encoding: 'BINARY'), encoding: 'BINARY')
      @format = :mp4
    ensure
      transcoded.close
      transcoded.unlink
    end
  end

  private

  def probe(key)
    @probe ||= `ffprobe -show_format -show_streams #{current_path} 2>/dev/null`.split("\n")
    @probe.find { |l| l.starts_with?("#{key}=") }.try { |line| line.split('=', 2).last }
  end

end
