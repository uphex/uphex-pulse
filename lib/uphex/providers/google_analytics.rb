require 'uphex/providers/configurable'
require 'rack/oauth2'

module UpHex
  module Providers
    class GoogleAnalytics
      include UpHex::Providers::Configurable

      attr_reader :request

      def initialize(request)
        @request    = request
        @identifier = config['identifier']
        @secret     = config['secret']
      end

      def make_consumer(params)
        Rack::OAuth2::Client.new params
      end

      def consumer_authorization_params
        {
          :identifier             => config['identifier'],
          :secret                 => config['secret'],
          :redirect_uri           => callback_url,
          :host                   => options['host'],
          :authorization_endpoint => options['authorization_endpoint']
        }
      end

      def config_authorization_params
        options['authorization_params']
      end

      def consumer_access_params
        {
          :identifier     => config['identifier'],
          :secret         => config['secret'],
          :redirect_uri   => callback_url,
          :host           => options['host'],
          :token_endpoint => options['token_endpoint']
        }
      end

      def make_authorization_request
        authorization_url
      end

      def authorization_url
        make_consumer(consumer_authorization_params).authorization_uri(config_authorization_params)
      end

      def make_access_request
        consumer.authorization_code = request.params[:code]
      end

      def callback_url
        request.url.split('?')[0] + "/callback"
      end
    end
  end
end
