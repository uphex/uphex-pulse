class GoogleAuthenticationStrategy < OAuthV2AuthenticationStrategy
  def callback(config,params,request,session)
    super

    return [].push(Hash['access_token'=>@token.access_token,'expiration_date'=>Time.now+@token.expires_in.to_i,'refresh_token'=>@token.refresh_token])
  end

  def profile_names(provider,config)
    client= Uphex::Prototype::Cynosure::Shiatsu.client(:google,config['oauth-v2']['providers']['google']['identifier'],config['oauth-v2']['providers']['google']['secret'])
    client.authenticate(provider.access_token,provider.expiration_date,provider.refresh_token)
    client.accounts.map{|account| account.name}
  end
end