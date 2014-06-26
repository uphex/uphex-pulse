require 'uphex/providers'
require 'active_support/inflector'

module UpHex
  module Providers
    module Configurable
      def config
        UpHex::Providers.config[provider_name]
      end

      def options
        config['options']
      end

      def provider_name
        self.class.name.demodulize.underscore.to_s
      end
    end
  end
end
