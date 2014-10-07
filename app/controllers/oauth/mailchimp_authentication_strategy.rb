class MailchimpAuthenticationStrategy < OAuthV2AuthenticationStrategy
  def callback(config,params,request,session)
    super

    [].push(Hash['access_token'=>@token.access_token])
  end

  def profiles(token,config)
    # TODO: It must be changed when the changes in Cynosure gets in
    [{:name=>'mailchimp',:id=>'1'}]
  end
end