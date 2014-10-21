class MailchimpAuthenticationStrategy < OAuthV2AuthenticationStrategy
  def callback(config,params,request,session)
    super

    dc=JSON.parse(@token.get('https://login.mailchimp.com/oauth2/metadata').content)['dc']

    [].push(Hash['access_token'=>@token.access_token+'-'+dc])
  end

  def profiles(token,config)
    client= Uphex::Prototype::Cynosure::Shiatsu.client(:mailchimp,config['oauth-v2']['providers']['mailchimp']['identifier'],config['oauth-v2']['providers']['mailchimp']['secret'])
    client.authenticate(token['access_token'])
    [{:name=>client.profile['account_name'],:id=>client.profile['id']}]
  end
end