json.s3Host(defined?(S3_HOST) ? "#{S3_BUCKET_NAME}.#{S3_HOST}" : nil)
json.env Rails.env

json.csrfParams do
  json.set! request_forgery_protection_token, form_authenticity_token
end
