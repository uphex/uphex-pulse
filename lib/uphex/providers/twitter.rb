require 'uphex/providers/configurable'
require 'oauth'
require 'twitter'
require 'uri'

module UpHex
  module Providers
    class Twitter
      # TODO: move session-storage stuff out of providers
      include UpHex::Providers::Configurable

      attr_reader :consumer_key
      attr_reader :consumer_secret
      attr_reader :oauth_verifier

      attr_reader :request

      attr_accessor :request_token
      attr_accessor :access_token

      def initialize(request)
        @request         = request

        @consumer_key    = config['consumer_key']
        @consumer_secret = config['consumer_secret']
        @oauth_verifier  = request.params['oauth_verifier']
      end

      def client
        raise RuntimeError.new("not yet authenticated") unless authenticated?
        @client ||= Twitter::REST::Client.new do |c|
          c.consumer_key        = consumer_key
          c.consumer_secret     = consumer_secret
          c.access_token        = access_token.token
          c.access_token_secret = access_token.secret
        end
      end

      def consumer
        @consumer ||= OAuth::Consumer.new(consumer_key, consumer_secret, options)
      end

      def access_tokens
        [self.access_token].compact
      end

      def authenticated?
        [
          consumer_key,
          consumer_secret,
          access_token,
        ].all?
      end

      def requested?
        !!self.request_token
      end

      def make_authorization_request
        self.request_token = consumer.get_request_token(:oauth_callback => callback_url)
      end

      def populate_request_token(token, secret)
        self.request_token = OAuth::RequestToken.new(consumer, token, secret)
      end

      def make_access_request
        self.access_token = request_token.get_access_token(:oauth_verifier => oauth_verifier)
      end

      def authorization_url
        raise RuntimeError.new("no request token present") unless requested?
        self.request_token.authorize_url
      end

      def callback_url
        request.url.split('?')[0] + "/callback"
      end
    end
  end
end
