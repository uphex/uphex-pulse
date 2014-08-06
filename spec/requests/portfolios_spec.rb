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
  end
end