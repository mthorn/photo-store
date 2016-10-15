AWS_ACCESS_KEY_ID = ENV['AWS_ACCESS_KEY_ID'].presence
AWS_SECRET_ACCESS_KEY = ENV['AWS_SECRET_ACCESS_KEY'].presence
AWS_REGION = ENV['AWS_REGION'].presence
S3_BUCKET_NAME = ENV['S3_BUCKET_NAME'].presence
ELASTIC_TRANSCODER_PIPELINE_ID = ENV['ELASTIC_TRANSCODER_PIPELINE_ID'].presence
ELASTIC_TRANSCODER_PRESET_ID = ENV['ELASTIC_TRANSCODER_PRESET_ID'].presence || '1351620000001-100060'
FFMPEG_EXTRACT_FRAME = ENV.fetch('FFMPEG_EXTRACT_FRAME', 'ffmpeg -y -i INPUT -ss TIME -r 1 -t 1 OUTPUT')
FFMPEG_TRANSCODE = ENV.fetch('FFMPEG_TRANSCODE', 'ffmpeg -y -i INPUT -c:v libx264 -c:a aac -map_metadata -1 -s SCALE OUTPUT')
FFMPEG_FIX_EXTRACTED_FRAME_ROTATION = ENV.fetch('FFMPEG_FIX_EXTRACTED_FRAME_ROTATION', 'false') == 'true'

aws_available = [ AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION, S3_BUCKET_NAME ].all?(&:present?)

CARRIERWAVE_STORAGE = ENV['CARRIERWAVE_STORAGE'].presence.try(:to_sym) || (aws_available ? :s3 : :file)
TRANSCODE_METHOD = ENV['TRANSCODE_METHOD'].presence.try(:to_sym) ||
  (CARRIERWAVE_STORAGE == :s3 && ELASTIC_TRANSCODER_PIPELINE_ID ? :aws : :ffmpeg)

if aws_available
  S3_HOST = AWS_REGION == 'us-east-1' ? 's3.amazonaws.com' : "s3-#{AWS_REGION}.amazonaws.com"

  fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: AWS_ACCESS_KEY_ID,
    aws_secret_access_key: AWS_SECRET_ACCESS_KEY,
    region: AWS_REGION
  }

  S3 = Fog::Storage.new fog_credentials

  if TRANSCODE_METHOD == :aws
    raise "TRANSCODE_METHOD :aws requires CARRIERWAVE_STORAGE == :s3" unless CARRIERWAVE_STORAGE == :s3
    AWS_TRANSCODER = Aws::ElasticTranscoder::Client.new(
      region: AWS_REGION,
      access_key_id: AWS_ACCESS_KEY_ID,
      secret_access_key: AWS_SECRET_ACCESS_KEY
    )
  else
    AWS_TRANSCODER = nil
  end
else
  S3 = nil
  AWS_TRANSCODER = nil
end

if CARRIERWAVE_STORAGE == :file && Rails.env.production?
  Rails.application.configure do
    config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX
  end
end

CarrierWave.configure do |config|
  config.cache_dir = "#{::Rails.root}/private/#{::Rails.env}_uploads/tmp"
  config.storage = CARRIERWAVE_STORAGE == :s3 ? :fog : CARRIERWAVE_STORAGE

  if CARRIERWAVE_STORAGE == :s3
    config.fog_credentials = fog_credentials
    config.fog_directory = S3_BUCKET_NAME
    config.fog_public = false
  end
end
