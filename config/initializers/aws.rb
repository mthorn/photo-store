AWS_ACCESS_KEY_ID = ENV['AWS_ACCESS_KEY_ID'].presence
AWS_SECRET_ACCESS_KEY = ENV['AWS_SECRET_ACCESS_KEY'].presence
AWS_REGION = ENV['AWS_REGION'].presence
S3_BUCKET_NAME = ENV['S3_BUCKET_NAME'].presence
ELASTIC_TRANSCODER_PIPELINE_ID = ENV['ELASTIC_TRANSCODER_PIPELINE_ID'].presence
ELASTIC_TRANSCODER_PRESET_ID = ENV['ELASTIC_TRANSCODER_PRESET_ID'].presence || '1351620000001-100060'

aws_available = [ AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION, S3_BUCKET_NAME ].all?(&:present?)

if aws_available
  S3_HOST = AWS_REGION == 'us-east-1' ? 's3.amazonaws.com' : "s3-#{AWS_REGION}.amazonaws.com"

  fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: AWS_ACCESS_KEY_ID,
    aws_secret_access_key: AWS_SECRET_ACCESS_KEY,
    region: AWS_REGION
  }

  S3 = Fog::Storage.new fog_credentials

  TRANSCODER = Aws::ElasticTranscoder::Client.new(
    region: AWS_REGION,
    access_key_id: AWS_ACCESS_KEY_ID,
    secret_access_key: AWS_SECRET_ACCESS_KEY
  )
else
  S3 = nil
  TRANSCODER = nil
end

CarrierWave.configure do |config|
  config.cache_dir = "#{::Rails.env}_uploads/tmp"

  if aws_available
    config.storage = :fog
    config.fog_credentials = fog_credentials
    config.fog_directory = S3_BUCKET_NAME
    config.fog_public = false
  else
    config.storage = :file
  end
end
