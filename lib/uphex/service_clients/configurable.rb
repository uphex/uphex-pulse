module UpHex
  module ServiceClients
    module Configurable
      def config
        @config || (raise RuntimeError.new("must initialize #config"))
      end

      def identifier
        config[:identifier]
      end

      def secret
        config[:secret]
      end
    end
  end
end
