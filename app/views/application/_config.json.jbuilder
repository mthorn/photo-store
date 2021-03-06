json.s3Host(defined?(S3_HOST) ? "#{S3_BUCKET_NAME}.#{S3_HOST}" : nil)
json.env Rails.env

json.csrfParams do
  json.set! request_forgery_protection_token, form_authenticity_token
end

if user_signed_in?
  json.user do
    json.partial! 'users/user', user: current_user
  end
  json.libraries current_user.library_memberships.includes(:library) do |library_membership|
    json.partial! 'libraries/library', library_membership: library_membership
  end
end
