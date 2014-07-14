require 'legato'

module UpHex
  module ServiceClients
    class GoogleAnalytics
      include UpHex::ServiceClients::Configurable

      def initialize(config)
        @config = config
      end
    end
  end
end
