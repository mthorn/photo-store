AWS_ACCESS_KEY_ID = ENV['AWS_ACCESS_KEY_ID'].presence
AWS_SECRET_ACCESS_KEY = ENV['AWS_SECRET_ACCESS_KEY'].presence
S3_BUCKET_NAME = ENV['S3_BUCKET_NAME'].presence
S3_REGION = ENV['S3_REGION']

s3_available = [ AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, S3_BUCKET_NAME, S3_REGION ].all?(&:present?)

if s3_available
  S3_HOST = S3_REGION == 'us-east-1' ? 's3.amazonaws.com' : "s3-#{S3_REGION}.amazonaws.com"

  fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: AWS_ACCESS_KEY_ID,
    aws_secret_access_key: AWS_SECRET_ACCESS_KEY,
    region: S3_REGION
  }

  S3 = Fog::Storage.new fog_credentials
else
  S3 = nil
end

CarrierWave.configure do |config|
  config.cache_dir = "#{::Rails.env}_uploads/tmp"

  if s3_available
    config.storage = :fog
    config.fog_credentials = fog_credentials
    config.fog_directory = S3_BUCKET_NAME
    config.fog_public = false
  else
    config.storage = :file
  end
end
