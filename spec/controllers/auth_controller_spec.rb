require 'environment_spec_helper'
require 'ostruct'

describe 'AuthController' do

  before do
    ResqueSpec.reset!
  end

  it 'should redirect to twitter' do
    expect(:get => '/auth/oauth-v1/twitter').to be_routable

    create_sample_user

    OAuth::Consumer.any_instance.stub(:get_request_token=>OpenStruct.new({:token => 'token', :secret => 'secret',:authorize_url=>'https://api.twitter.com'}))

    get '/auth/oauth-v1/twitter'
    expect(last_response.status).to eq 302
    expect(last_response.headers['Location']).to eql 'https://api.twitter.com'
  end

  it 'should redirect to google' do
    expect(:get => '/auth/oauth-v2/google').to be_routable

    create_sample_user

    get '/auth/oauth-v2/google'
    expect(last_response.status).to eq 302
    expect(last_response.headers['Location']).to start_with 'https://accounts.google.com'
  end

  it 'should redirect to facebook' do
    expect(:get => '/auth/oauth-v2/facebook').to be_routable

    create_sample_user

    get '/auth/oauth-v2/facebook'
    expect(last_response.status).to eq 302
    expect(last_response.headers['Location']).to start_with 'https://www.facebook.com'
  end

  it 'should create a provider if only 1 profile is returned upon callback' do
    expect(:get => '/auth/oauth-v2/google/callback').to be_routable

    create_sample_user
    create_sample_portfolio

    Rack::OAuth2::Client.any_instance.should_receive(:authorization_code=) do |arg|
      expect(arg).to eql 'sample_code'
    end

    Rack::OAuth2::Client.any_instance.stub(:access_token!) do |arg|
      OpenStruct.new({:access_token=>'access_token',:expires_in=>DateTime.now+1.days,:refresh_token=>'refresh_token'})
    end

    Legato::User.any_instance.stub(:accounts=>[OpenStruct.new({:id=>'account_id',:name=>'account',:profiles=>[OpenStruct.new({:name=>'test_profile',:id=>'test_profile_id'})]})])

    get '/auth/oauth-v2/google/callback?state='+CGI::escape({:portfolioid=>Portfolio.all.first.id}.to_json)+'&code=sample_code'

    expect(Provider.all).not_to be_empty
    expect(Provider.all.first.portfolio.id).to eql Portfolio.all.first.id
    expect(Provider.all.first.profile_id).to eql 'test_profile_id'
    expect(Provider.all.first.access_token).to eql 'access_token'
    expect(Provider.all.first.refresh_token).to eql 'refresh_token'
  end

  it 'should redirect to the selector page if multiple profiles are present' do
    create_sample_user
    create_sample_portfolio

    Rack::OAuth2::Client.any_instance.stub(:access_token!) do |arg|
      OpenStruct.new({:access_token=>'access_token',:expires_in=>DateTime.now+1.days,:refresh_token=>'refresh_token'})
    end

    Legato::User.any_instance.stub(:accounts=>[OpenStruct.new({:id=>'account_id',:name=>'account',:profiles=>[OpenStruct.new({:name=>'test_profile',:id=>'test_profile_id1'}),OpenStruct.new({:name=>'test_profile2',:id=>'test_profile_id2'})]})])

    get '/auth/oauth-v2/google/callback?state='+CGI::escape({:portfolioid=>Portfolio.all.first.id}.to_json)+'&code=sample_code'

    expect(Provider.all).to be_empty

    expect(last_response.body).to include 'provider_0'
    expect(last_response.body).to include 'provider_1'
    expect(last_response.body).not_to include 'provider_2'
    expect(last_response.body).to include 'test_profile_id1'
    expect(last_response.body).to include 'test_profile_id2'

    post '/auth/add_providers',{:provider_selected=>['0'],:provider_0=>YAML::dump({:portfolios_id=>Portfolio.all.first.id,:profile_id=>'test_profile_id1',:provider_name=>'google',:refresh_token=>'refresh_token',:access_token=>'access_token',:userid=>User.all.first.id,:name=>'account/test_profile'})}

    expect(Provider.all).not_to be_empty
    expect(Provider.all.size).to eql 1
    expect(Provider.all.first.portfolio.id).to eql Portfolio.all.first.id
    expect(Provider.all.first.profile_id).to eql 'test_profile_id1'
    expect(Provider.all.first.access_token).to eql 'access_token'
    expect(Provider.all.first.refresh_token).to eql 'refresh_token'
  end

  it 'should be add multiple providers if multiple is selected' do
    create_sample_user
    create_sample_portfolio

    Rack::OAuth2::Client.any_instance.stub(:access_token!) do |arg|
      OpenStruct.new({:access_token=>'access_token',:expires_in=>DateTime.now+1.days,:refresh_token=>'refresh_token'})
    end

    Legato::User.any_instance.stub(:accounts=>[OpenStruct.new({:id=>'account_id',:name=>'account',:profiles=>[OpenStruct.new({:name=>'test_profile',:id=>'test_profile_id1'}),OpenStruct.new({:name=>'test_profile2',:id=>'test_profile_id2'})]})])

    get '/auth/oauth-v2/google/callback?state='+CGI::escape({:portfolioid=>Portfolio.all.first.id}.to_json)+'&code=sample_code'

    post '/auth/add_providers',{:provider_selected=>['0','1'],:provider_0=>YAML::dump({:portfolios_id=>Portfolio.all.first.id,:profile_id=>'test_profile_id1',:provider_name=>'google',:refresh_token=>'refresh_token',:access_token=>'access_token',:userid=>User.all.first.id,:name=>'account/test_profile'}),:provider_1=>YAML::dump({:portfolios_id=>Portfolio.all.first.id,:profile_id=>'test_profile_id2',:provider_name=>'google',:refresh_token=>'refresh_token',:access_token=>'access_token',:userid=>User.all.first.id,:name=>'account/test_profile2'})}

    expect(Provider.all.size).to eql 2
  end

  it 'should enque a StreamCreate job when creating a provider' do
    create_sample_user
    create_sample_portfolio

    Rack::OAuth2::Client.any_instance.stub(:access_token!) do |arg|
      OpenStruct.new({:access_token=>'access_token',:expires_in=>DateTime.now+1.days,:refresh_token=>'refresh_token'})
    end

    Legato::User.any_instance.stub(:accounts=>[OpenStruct.new({:id=>'account_id',:name=>'account',:profiles=>[OpenStruct.new({:name=>'test_profile',:id=>'test_profile_id'})]})])

    get '/auth/oauth-v2/google/callback?state='+CGI::escape({:portfolioid=>Portfolio.all.first.id}.to_json)+'&code=sample_code'

    StreamCreate.should have_queued(Provider.all.first.id)
    StreamCreate.should have_queue_size_of(1)

    expect(Metric.all.size).to eql 0
    ResqueSpec.perform_all(:StreamCreate)

    expect(Metric.all.size).to eql 3
    MetricUpdate.should have_queue_size_of(3)

  end

  it 'should refresh a provider if reauth_to is specified' do
    create_sample_user
    create_sample_portfolio

    Rack::OAuth2::Client.any_instance.stub(:access_token!) do |arg|
      OpenStruct.new({:access_token=>'access_token',:expires_in=>DateTime.now+1.days,:refresh_token=>'refresh_token'})
    end

    Legato::User.any_instance.stub(:accounts=>[OpenStruct.new({:id=>'account_id',:name=>'account',:profiles=>[OpenStruct.new({:name=>'test_profile',:id=>'test_profile_id1'}),OpenStruct.new({:name=>'test_profile2',:id=>'test_profile_id2'})]})])

    get '/auth/oauth-v2/google/callback?state='+CGI::escape({:portfolioid=>Portfolio.all.first.id}.to_json)+'&code=sample_code'

    post '/auth/add_providers',{:provider_selected=>['0'],:provider_0=>YAML::dump({:portfolios_id=>Portfolio.all.first.id,:profile_id=>'test_profile_id1',:provider_name=>'google',:refresh_token=>'refresh_token',:access_token=>'access_token',:userid=>User.all.first.id,:name=>'account/test_profile'})}

    Rack::OAuth2::Client.any_instance.stub(:access_token!) do |arg|
      OpenStruct.new({:access_token=>'access_token2',:expires_in=>DateTime.now+1.days,:refresh_token=>'refresh_token2'})
    end

    get '/auth/oauth-v2/google/callback?state='+CGI::escape({:portfolioid=>Portfolio.all.first.id,:reauth_to=>Provider.all.first.id}.to_json)+'&code=sample_code'

    expect(Provider.all).not_to be_empty
    expect(Provider.all.size).to eql 1
    expect(Provider.all.first.portfolio.id).to eql Portfolio.all.first.id
    expect(Provider.all.first.profile_id).to eql 'test_profile_id1'
    expect(Provider.all.first.access_token).to eql 'access_token2'
    expect(Provider.all.first.refresh_token).to eql 'refresh_token2'
  end
end
