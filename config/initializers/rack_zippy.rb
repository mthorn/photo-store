Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Zippy::AssetServer
Rails.application.config.middleware.delete 'Rack::Sendfile'
