require 'uphex'

module UpHex
  module Providers
    class << self
      def config
        @config ||= {}
      end
    end
  end
end
