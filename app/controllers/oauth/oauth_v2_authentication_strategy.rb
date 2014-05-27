require 'rack/oauth2'
class OAuthV2AuthenticationStrategy
  def getRedirectUri(config,request,session,portfolioid)
    client = Rack::OAuth2::Client.new(
        :identifier => config['identifier'],
        :secret => config['secret'],
        :redirect_uri => request.url.split('?')[0]+'/callback', # only required for grant_type = :code
        :host => config['host'],
        :authorization_endpoint=>config['authorization_endpoint']
    )

    params=config['authorization_params'].clone
    params[:state]=portfolioid

    url=client.authorization_uri(params)

    return url
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

    Rack::OAuth2.debugging =true

    @token=client.access_token!(:authorization_code)
  end

  def getPortfolioid(params,session)
    params[:state]
  end
end