module UpHex
  module Initializers
    module HoneybadgerSupport
      def self.registered(app)
        if RACK_ENV == 'production'
          Honeybadger.configure do |config|
            config.api_key = '4c276868'
          end

          app.use Honeybadger::Rack::ErrorNotifier
          app.logger.debug "registering Honeybadger"
        else
          app.logger.debug "skipping Honeybadger registration because RACK_ENV is [#{RACK_ENV}]"
        end
      end
    end
  end
end
