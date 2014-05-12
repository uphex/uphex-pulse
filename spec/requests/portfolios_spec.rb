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
  end
end