class StripeAuthenticationStrategy < OAuthV2AuthenticationStrategy
  def callback(config,params,request,session)
    super

    [].push(Hash['access_token' => @token.access_token])
  end

  def profiles(token,config)
    client = Uphex::Prototype::Cynosure::Shiatsu.client(
      :stripe,
      config['oauth-v2']['providers']['stripe']['identifier'],
      config['oauth-v2']['providers']['stripe']['secret']
    )
    client.authenticate(token['access_token'])
    [{:name => client.profile['display_name'],:id => client.profile['id'].to_s}]
  end
end