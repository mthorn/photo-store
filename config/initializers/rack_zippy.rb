Rails.application.config.middleware.insert_after Rack::Cors, Rack::Zippy::AssetServer
Rails.application.config.middleware.delete 'Rack::Sendfile'
