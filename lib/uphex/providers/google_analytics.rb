require 'uphex/providers/configurable'
require 'rack/oauth2'
require 'legato'

module UpHex
  module Providers
    class GoogleAnalytics
      include UpHex::Providers::Configurable

      def initialize(request)
        @request    = request
        @identifier = config['identifier']
        @secret     = config['secret']
      end

      def consumer
        @consumer ||= Rack::OAuth2::Client.new(consumer_params)
      end

      def consumer_params
        {
          :identifier             => config['identifier'],
          :secret                 => config['secret'],
          :redirect_uri           => callback_url,
          :host                   => options['host'],
          :authorization_endpoint => options['authorization_endpoint']
        }
      end

      def make_authorization_request

      end

      def callback_url
        request.url.split('?')[0] + "/callback"
      end
    end
  end
end
