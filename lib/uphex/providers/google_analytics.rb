require 'uphex/providers/configurable'
require 'uri'
require 'oauth2'

module UpHex
  module Providers
    class GoogleAnalytics
      include UpHex::Providers::Configurable

      attr_reader :request

      def initialize(request, additional_params = {})
        @request    = request
        request.params.merge! additional_params
        @identifier = config['identifier']
        @secret     = config['secret']
      end

      def make_client
        OAuth2::Client.new(
          config.fetch('identifier'),
          config.fetch('secret'),
          {
            :authorize_url => URI.join(options.fetch('service_root_uri'), options.fetch('authorization_endpoint')),
            :token_url     => URI.join(options.fetch('service_root_uri'), options.fetch('token_endpoint')),
          }
        )
      end

      def access_token_code
        request.params.fetch 'code'
      end

      def make_authorization_request
        authorization_url
      end

      # Returns an OAuth2::AccessToken
      def make_access_token_request
        puts "... using callback: #{self.callback_url}"
        make_client.auth_code.get_token(self.access_token_code, :redirect_uri => self.callback_url)
      end

      def config_authorization_params
        options['authorization_params']
      end

      def authorization_params
        config_authorization_params.merge :redirect_uri => callback_url
      end

      def authorization_url
        make_client.auth_code.authorize_url(authorization_params)
      end

      def callback_url
        root_uri = request.url.split('?').first
        root_uri.gsub('/callback', '') + '/callback'
      end
    end
  end
end
