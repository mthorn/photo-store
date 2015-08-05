json.s3DirectUpload S3.present?
json.s3Host "#{S3_BUCKET_NAME}.#{S3_HOST}"
json.env Rails.env

json.csrfParams do
  json.set! request_forgery_protection_token, form_authenticity_token
end
