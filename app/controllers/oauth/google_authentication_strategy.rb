class GoogleAuthenticationStrategy < OAuthV2AuthenticationStrategy
  def callback(config,params,request,session)
    super

    return [].push(Hash['access_token'=>@token.access_token,'expiration_date'=>Time.now+@token.expires_in.to_i,'refresh_token'=>@token.refresh_token])
  end

  def profiles(token,config)
    client= Uphex::Prototype::Cynosure::Shiatsu.client(:google,config['oauth-v2']['providers']['google']['identifier'],config['oauth-v2']['providers']['google']['secret'])
    client.authenticate(token['access_token'])
    client.accounts.map { |account| client.profiles_for_account(account.id).map { |profile|
      {:name => account.name+'/'+profile.name, :id => profile.id}
    }
    }.flatten
  end
end