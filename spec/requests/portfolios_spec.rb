require 'environment_spec_helper'

describe "portfolios" do
  context "manages portfolio" do
    it "creates a portfolio" do
      create_sample_user

      post '/portfolios',
           :authenticity_token => 'foo',
           :portfolio => {
               :organization => Organization.all.first.id,
               :name => 'test_portfolio'
           }

      follow_redirect!

      expect(last_response.body).to include "Portfolio created"
      expect(last_response.body).to include "test_portfolio"
    end

    it "modifies a portfolio" do
      create_sample_user
      create_sample_portfolio

      put '/portfolios/'+Portfolio.all.first.id.to_s,{
          :authenticity_token => 'foo',
          :portfolio => {
              :name=>'new_portfolio_name'
          }
      }

      follow_redirect!

      expect(last_response.body).to include "new_portfolio_name"

      get '/'
      follow_redirect!
      expect(last_response.body).to include "new_portfolio_name"

      get '/clients/'+Portfolio.all.first.id.to_s
      expect(last_response.body).to include "new_portfolio_name"
    end

    it 'deletes a provider from a portfolio' do
      create_sample_user
      create_sample_portfolio
      create_sample_metric

      expect(Provider.all.size).to eq 1

      get '/clients/'+Portfolio.first.id.to_s
      expect(last_response.body).to include "account/test_profile"
      get '/portfolios/'+Portfolio.first.id.to_s
      expect(last_response.body).to include "account/test_profile"
      get '/users/me/dashboard'
      expect(last_response.body).not_to include "Client has no streams"

      delete '/providers/'+Provider.first.id.to_s

      get '/clients/'+Portfolio.first.id.to_s
      expect(last_response.body).not_to include "account/test_profile"
      get '/portfolios/'+Portfolio.first.id.to_s
      expect(last_response.body).not_to include "account/test_profile"
      get '/users/me/dashboard'
      expect(last_response.body).to include "Client has no streams"

      #the provider is not deleted, just hidden from the portfolio
      expect(Provider.all.size).to eq 1
    end

    it 'deletes a portfolio' do
      create_sample_user
      create_sample_portfolio

      expect(Portfolio.all.size).to eq 1

      portfolio_id=Portfolio.first.id.to_s

      get '/users/me/dashboard'
      expect(last_response.body).to include "test_portfolio"

      get '/portfolios/'+portfolio_id
      expect(last_response.status).to eq 200

      get '/portfolios/'+portfolio_id
      expect(last_response.body).to include "Delete"

      delete '/portfolios/'+portfolio_id
      follow_redirect!
      expect(last_response.body).to include "Portfolio deleted"

      get '/portfolios/'+portfolio_id
      expect(last_response.status).to eq 403
      expect(Portfolio.all.size).to eq 1

      get '/users/me/dashboard'
      expect(last_response.body).not_to include "test_portfolio"
    end

    it 'should not be able to access a provider from a deleted portfolio' do
      create_sample_user
      create_sample_portfolio
      create_sample_metric

      get '/providers/'+Provider.first.id.to_s
      expect(last_response.status).to eq 200

      delete '/portfolios/'+Portfolio.first.id.to_s

      get '/providers/'+Provider.first.id.to_s
      expect(last_response.status).to eq 403
    end

    it 'should not show the events for deleted providers and portfolios' do
      create_sample_user
      create_sample_portfolio
      create_sample_metric

      get '/users/me/dashboard'
      expect(last_response.body).to include "No events"
      get '/clients/'+Portfolio.first.id.to_s
      expect(last_response.body).to include "No events"

      Observation.create(:index=>Time.utc(2014,02,27),:value=>2,:metric=>Metric.first).save!
      Observation.create(:index=>Time.utc(2014,02,28),:value=>2,:metric=>Metric.first).save!
      event1=Event.create(:date=>Time.utc(2014,02,27),:prediction_low=>0,:prediction_high=>1,:metric=>Metric.first)
      event1.save!

      get '/users/me/dashboard'
      expect(last_response.body).not_to include "No events"
      get '/clients/'+Portfolio.first.id.to_s
      expect(last_response.body).not_to include "No events"
      get '/events'
      expect(last_response.body).not_to include "No events"
      get '/events/'+event1.id.to_s
      expect(last_response.status).to eq 200

      delete '/providers/'+Provider.first.id.to_s

      get '/users/me/dashboard'
      expect(last_response.body).to include "No events"
      get '/clients/'+Portfolio.first.id.to_s
      expect(last_response.body).to include "No events"
      get '/events'
      expect(last_response.body).to include "No events"
      get '/events/'+event1.id.to_s
      expect(last_response.status).to eq 403

      provider=Provider.create({:portfolios_id=>Portfolio.all.first.id,:profile_id=>'test_profile_id2',:provider_name=>'google',:refresh_token=>'refresh_token',:access_token=>'access_token',:userid=>User.all.first.id,:name=>'account/test_profile2',:expiration_date=>DateTime.now+1.days})
      metric=Metric.create({:provider=>provider,:name=>'visits',:updated_at=>DateTime.new,:analyzed_at=>DateTime.new})
      Observation.create(:index=>Time.utc(2014,02,27),:value=>2,:metric=>metric).save!
      Observation.create(:index=>Time.utc(2014,02,28),:value=>2,:metric=>metric).save!
      event2=Event.create(:date=>Time.utc(2014,02,27),:prediction_low=>0,:prediction_high=>1,:metric=>metric)
      event2.save!

      get '/users/me/dashboard'
      expect(last_response.body).not_to include "No events"
      get '/clients/'+Portfolio.first.id.to_s
      expect(last_response.body).not_to include "No events"
      get '/events'
      expect(last_response.body).not_to include "No events"
      get '/events/'+event2.id.to_s
      expect(last_response.status).to eq 200

      delete '/portfolios/'+Portfolio.first.id.to_s

      get '/users/me/dashboard'
      expect(last_response.body).to include "No events"
      get '/events'
      expect(last_response.body).to include "No events"
      get '/events/'+event2.id.to_s
      expect(last_response.status).to eq 403
    end

    it 'should prompt for restore when a deleted portfolio is created again' do
      create_sample_user
      create_sample_portfolio

      delete '/portfolios/'+Portfolio.first.id.to_s

      post '/portfolios', :portfolio=>{:name=>Portfolio.first.name,:organization=>Organization.first.id}
      expect(last_response.body).to include "Would you like to restore the deleted portfolio"
      expect(last_response.body).to include Portfolio.first.name

      post '/portfolios/restore/'+Portfolio.first.id.to_s
      follow_redirect!
      expect(last_response.body).to include "restored"

      expect(Portfolio.all.size).to eq 1
      expect(Portfolio.first.deleted).to eq false
    end

    it 'should restore a deleted provider with updated keys when a deleted one exists for the same provider and profile' do
      create_sample_user
      create_sample_portfolio
      create_sample_metric

      delete '/providers/'+Provider.first.id.to_s

      expect(Provider.all.size).to eq 1

      Rack::OAuth2::Client.any_instance.stub(:access_token!) do |arg|
        OpenStruct.new({:access_token=>'new_access_token',:expires_in=>DateTime.now+1.days,:refresh_token=>'new_refresh_token'})
      end

      Legato::User.any_instance.stub(:accounts=>[OpenStruct.new({:id=>'account_id',:name=>'account',:profiles=>[OpenStruct.new({:name=>Provider.first.name,:id=>Provider.first.profile_id})]})])

      get '/auth/oauth-v2/google/callback?state='+CGI::escape({:portfolioid=>Portfolio.all.first.id}.to_json)+'&code=sample_code'

      expect(Provider.all.size).to eq 1
      expect(Provider.first.access_token).to eq 'new_access_token'
      expect(Provider.first.refresh_token).to eq 'new_refresh_token'
      expect(Provider.first.deleted).to eq false
    end

    it 'should restore a deleted provider when one is selected from multiple profiles' do
      create_sample_user
      create_sample_portfolio
      create_sample_metric

      delete '/providers/'+Provider.first.id.to_s

      provider_id=Provider.first.id
      provider_name=Provider.first.name

      Rack::OAuth2::Client.any_instance.stub(:access_token!) do |arg|
        OpenStruct.new({:access_token=>'access_token',:expires_in=>DateTime.now+1.days,:refresh_token=>'refresh_token'})
      end

      Legato::User.any_instance.stub(:accounts=>[OpenStruct.new({:id=>'account_id',:name=>'account',:profiles=>[OpenStruct.new({:name=>Provider.first.name,:id=>Provider.first.profile_id}),OpenStruct.new({:name=>'test_profile2',:id=>'test_profile_id2'})]})])

      post '/auth/add_providers',{:portfolio_id=>Portfolio.first.id,:provider_selected=>['0','1'],:provider_0=>YAML::dump({:portfolios_id=>Portfolio.all.first.id,:profile_id=>Provider.first.profile_id,:provider_name=>'google',:refresh_token=>'new_refresh_token',:access_token=>'new_access_token',:userid=>User.all.first.id,:name=>'account/new_test_profile'}),:provider_1=>YAML::dump({:portfolios_id=>Portfolio.all.first.id,:profile_id=>'test_profile_id2',:provider_name=>'google',:refresh_token=>'refresh_token',:access_token=>'access_token',:userid=>User.all.first.id,:name=>'account/test_profile2'})}

      expect(Provider.all.size).to eq 2
      expect(Provider.find(provider_id).name).to eq provider_name
      expect(Provider.find(provider_id).deleted).to eq false
      expect(Provider.find(provider_id).access_token).to eq 'new_access_token'
      expect(Provider.find(provider_id).refresh_token).to eq 'new_refresh_token'
    end

  end
end