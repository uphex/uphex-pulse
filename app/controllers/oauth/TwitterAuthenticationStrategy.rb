class TwitterAuthenticationStrategy < OAuthV1AuthenticationStrategy
  def callback(config,params,request,session)
    @consumer = OAuth::Consumer.new(config['consumer_key'],config['consumer_secret'],config['options'])
    @consumer.http.set_debug_output($stderr)
    @req_token = OAuth::RequestToken.new(@consumer,session[:request_token],session[:request_token_secret])

    # Request user access info from Twitter
    @access_token = @req_token.get_access_token(:oauth_verifier=>params["oauth_verifier"])

    return [].push(Hash['access_token'=>@access_token.token,'access_token_secret'=>@access_token.secret])

  end

  def profile_names(provider,config)
    @consumer = OAuth::Consumer.new(config['oauth-v1']['providers']['twitter']['consumer_key'],config['oauth-v1']['providers']['twitter']['consumer_secret'],config['oauth-v1']['providers']['twitter']['options'])
    @access_token=OAuth::AccessToken.new(@consumer,provider.access_token,provider.access_token_secret)
    return JSON.parse(@access_token.request(:get, "https://api.twitter.com/1.1/account/settings.json").body)['screen_name']
  end
end