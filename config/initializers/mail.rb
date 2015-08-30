MAIL_DOMAIN =
  if Rails.env.development? && defined? Rails::Server
    'localhost:' + Rails::Server.new.options[:Port].to_s
  elsif Rails.env.production?
    ENV['HOST'] || 'unknown-domain'
  else
    'localhost'
  end

ActionMailer::Base.default_url_options = {
  host: MAIL_DOMAIN,
  only_path: false
}

Devise.setup do |config|
  config.mailer_sender = "no-reply@#{MAIL_DOMAIN}"
end

if Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com',
    :enable_starttls_auto => true
  }
end
