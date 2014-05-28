require 'environment_spec_helper'

describe "users" do
  context "signing up" do
    it "signs up and signs itself in" do
      set_csrf_token 'foo'

      params_hash = {
        :authenticity_token => 'foo',
        :user_registration => {
          :user_name => (user_name = 'Alice Smith'),
          :user_email => 'user@domain.com',
          :user_password => '123456',
          :organization_name => 'w'
        }
      }

      post '/users', params_hash
      expect(last_response.status).to eq 201

      get '/users/me'
      expect(last_request.env['warden'].user.name).to eq user_name
    end
  end
end
