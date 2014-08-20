require 'rack/oauth2'
require 'json'
require 'stringio'
require 'logger'

class OAuthV2AuthenticationStrategy

  #This is needed because we can only set class level logger to Rack:OAuth2
  @@lock = Mutex.new

  def lock
    @@lock
  end

  def getRedirectUri(config,request,session,portfolioid,reauth_to)
    client = Rack::OAuth2::Client.new(
        :identifier => config['identifier'],
        :secret => config['secret'],
        :redirect_uri => request.url.split('?')[0]+'/callback', # only required for grant_type = :code
        :host => config['host'],
        :authorization_endpoint=>config['authorization_endpoint']
    )

    params=config['authorization_params'].clone
    params[:state]={:portfolioid=>portfolioid,:reauth_to=>reauth_to}.to_json

    client.authorization_uri(params)
  end
  def callback(config,params,request,session)
    if request.port!=80
      @url=request.scheme.to_s+'://'+request.host.to_s+':'+request.port.to_s+request.path.to_s
    else
      @url=request.scheme.to_s+'://'+request.host.to_s+request.path.to_s
    end

    client = Rack::OAuth2::Client.new(
        :identifier => config['identifier'],
        :secret => config['secret'],
        :redirect_uri => @url, # only required for grant_type = :code
        :host => config['token_host'],
        :token_endpoint=>config['token_endpoint']
    )

    client.authorization_code = params[:code]

    lock.synchronize do
      Rack::OAuth2.debug do
        @strio = StringIO.new
        original_logger= Rack::OAuth2.logger
        Rack::OAuth2.logger =Logger.new @strio

        @token=client.access_token!(:authorization_code)
        Rack::OAuth2.logger =original_logger
      end
    end
  end

  def getPortfolioid(params,session)
    JSON.parse(params[:state])["portfolioid"]
  end

  def getReauthTo(params,session)
    JSON.parse(params[:state])["reauth_to"]
  end

  def raw_response
    @strio.string
  end
end