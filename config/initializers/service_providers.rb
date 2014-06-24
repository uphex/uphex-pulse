module UpHex
  module Initializers
    module ServiceProviders
      def self.registered(*)
        require 'erb'
        provider_config_file = Padrino.root 'config', 'providers.yml'
        providers_hash = YAML.load(ERB.new(File.read provider_config_file).result)['providers']
        UpHex::Providers.config.merge! providers_hash
      end
    end
  end
end
