require 'uphex/providers/twitter'
require 'uphex/providers/google_analytics'

UpHex::Pulse.controllers :authn do
  before do
    provider_source = UpHex::Providers
    @provider = provider_source.const_get params.fetch('provider_id').camelize
  end

  get '/:authn_strategy/twitter' do
    o = UpHex::Providers::Twitter.new(request)
    request_token = o.make_authorization_request
    session["providers.#{o.provider_name}.request_token"]        = request_token.token
    session["providers.#{o.provider_name}.request_token_secret"] = request_token.secret

    redirect o.authorization_url
  end

  get '/:authn_strategy/twitter/callback' do
    o = UpHex::Providers::Twitter.new(request)
    o.populate_request_token \
      session["providers.#{o.provider_name}.request_token"],
      session["providers.#{o.provider_name}.request_token_secret"]

    o.make_access_request

    "great success! we received these tokens: #{o.access_tokens.inspect} <br><br>we can now act as these users: #{o.access_tokens.map { |at| at.params[:screen_name] }}".html_safe
  end

  get '/:authn_strategy/:provider_id' do
    o = @provider.new(request)

    o.make_authorization_request

    redirect o.authorization_url
  end

  get '/:authn_strategy/:provider_id/callback' do
    o = @provider.new(request)
    token = o.make_access_token_request
  end
end
