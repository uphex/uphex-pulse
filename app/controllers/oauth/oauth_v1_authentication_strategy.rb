require 'oauth'
class OAuthV1AuthenticationStrategy

  def getRedirectUri(config,request,session,portfolioid,reauth_to)
    @consumer = OAuth::Consumer.new(config['consumer_key'],config['consumer_secret'],config['options'])
    @consumer.http.set_debug_output($stderr)
    @req_token = @consumer.get_request_token(:oauth_callback=>request.url.split('?')[0]+'/callback')

    session[:request_token] = @req_token.token
    session[:request_token_secret] = @req_token.secret
    session[:portfolioid] = portfolioid
    session[:reauth_to] = reauth_to
    return @req_token.authorize_url
  end

  def getPortfolioid(params,session)
    session[:portfolioid]
  end

  def getReauthTo(params,session)
    session[:reauth_to]
  end
end