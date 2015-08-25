module UploaderExtension

  def fix_exif_rotation
    manipulate! do |img|
      img.auto_orient
      img = yield(img) if block_given?
      img
    end
  end

  def quality(percentage)
    manipulate! do |img|
      img.quality percentage
      img = yield(img) if block_given?
      img
    end
  end

  def extract_frame(fraction)
    probe = `ffprobe -show_format -show_streams #{current_path} 2>/dev/null`.split("\n")

    frame = Tempfile.new(%w( frame .jpg ), encoding: 'BINARY')
    begin
      duration = probe.find { |l| l.starts_with?('duration=') }.try { |line| line.split('=', 2).last.to_f } || 0
      system('ffmpeg', '-y', '-i', current_path, '-ss', (duration * fraction).to_s, '-r', '1', '-t', '1', frame.path)
      return unless $? == 0

      rotate = probe.find { |l| l.starts_with?('TAG:rotate=') }.try { |r| r.split('=', 2).last }
      if rotate && rotate.to_i != 0
        system('mogrify', '-rotate', rotate, frame.path)
      end

      # avoid frame.read() - seems to cache the unrotated version
      File.write(current_path, File.read(frame.path, encoding: 'BINARY'), encoding: 'BINARY')
      @format = :jpg
    ensure
      frame.close
      frame.unlink
    end
  end

end
