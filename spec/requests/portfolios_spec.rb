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

      expect(Provider.all.size).to eql 1

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
      expect(Provider.all.size).to eql 1
    end

    it 'deletes a portfolio' do
      create_sample_user
      create_sample_portfolio

      expect(Portfolio.all.size).to eql 1

      portfolio_id=Portfolio.first.id.to_s

      get '/users/me/dashboard'
      expect(last_response.body).to include "test_portfolio"

      get '/portfolios/'+portfolio_id
      expect(last_response.status).to eql 200

      get '/portfolios/'+portfolio_id
      expect(last_response.body).to include "Delete"

      delete '/portfolios/'+portfolio_id
      follow_redirect!
      expect(last_response.body).to include "Portfolio deleted"

      get '/portfolios/'+portfolio_id
      expect(last_response.status).to eql 403
      expect(Portfolio.all.size).to eql 1

      get '/users/me/dashboard'
      expect(last_response.body).not_to include "test_portfolio"
    end

    it 'should not be able to access a provider from a deleted portfolio' do
      create_sample_user
      create_sample_portfolio
      create_sample_metric

      get '/providers/'+Provider.first.id.to_s
      expect(last_response.status).to eql 200

      delete '/portfolios/'+Portfolio.first.id.to_s

      get '/providers/'+Provider.first.id.to_s
      expect(last_response.status).to eql 403
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
      Event.create(:date=>Time.utc(2014,02,27),:prediction_low=>0,:prediction_high=>1,:metric=>Metric.first).save!

      get '/users/me/dashboard'
      expect(last_response.body).not_to include "No events"
      get '/clients/'+Portfolio.first.id.to_s
      expect(last_response.body).not_to include "No events"

      delete '/providers/'+Provider.first.id.to_s

      get '/users/me/dashboard'
      expect(last_response.body).to include "No events"
      get '/clients/'+Portfolio.first.id.to_s
      expect(last_response.body).to include "No events"

      provider=Provider.create({:portfolios_id=>Portfolio.all.first.id,:profile_id=>'test_profile_id2',:provider_name=>'google',:refresh_token=>'refresh_token',:access_token=>'access_token',:userid=>User.all.first.id,:name=>'account/test_profile2',:expiration_date=>DateTime.now+1.days})
      metric=Metric.create({:provider=>provider,:name=>'visits',:updated_at=>DateTime.new,:analyzed_at=>DateTime.new})
      Observation.create(:index=>Time.utc(2014,02,27),:value=>2,:metric=>metric).save!
      Observation.create(:index=>Time.utc(2014,02,28),:value=>2,:metric=>metric).save!
      Event.create(:date=>Time.utc(2014,02,27),:prediction_low=>0,:prediction_high=>1,:metric=>metric).save!

      get '/users/me/dashboard'
      expect(last_response.body).not_to include "No events"
      get '/clients/'+Portfolio.first.id.to_s
      expect(last_response.body).not_to include "No events"

      delete '/portfolios/'+Portfolio.first.id.to_s

      get '/users/me/dashboard'
      expect(last_response.body).to include "No events"
    end
  end
end