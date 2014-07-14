require 'uphex/providers/twitter'

UpHex::Pulse.controllers :authn do
  get '/:authn_strategy/twitter' do
    o = UpHex::Providers::Twitter.new(request)
    request_token = o.make_authorization_request
    session["providers.#{o.provider_name}.request_token"]        = request_token.token
    session["providers.#{o.provider_name}.request_token_secret"] = request_token.secret

    puts request.params.inspect
    puts request.session.inspect

    redirect o.authorization_url
  end

  get '/:authn_strategy/twitter/callback' do
    o = UpHex::Providers::Twitter.new(request)
    o.populate_request_token \
      session["providers.#{o.provider_name}.request_token"],
      session["providers.#{o.provider_name}.request_token_secret"]

    o.make_access_request

    puts request.params.inspect
    puts request.session.inspect

    "great success! we received these tokens: #{o.access_tokens.inspect} <br><br>we can now act as these users: #{o.access_tokens.map { |at| at.params[:screen_name] }}".html_safe
  end

  get '/:authn_strategy/google_analytics' do
    o = UpHex::Providers::GoogleAnalytics.new(request)

    o.make_authorization_request

    redirect o.authorization_url
  end

  get '/:authn_strategy/google_analytics/callback' do
    o = UpHex::Providers::GoogleAnalytics.new(request)
    o.make_access_request

    "great success! Google Analytics callback!<br>
    -- we received this request: #{request.params}<br>
    -- we received this object: #{o}<br>
    ".html_safe
  end
end
