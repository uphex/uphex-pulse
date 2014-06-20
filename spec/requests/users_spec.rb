require 'environment_spec_helper'
require 'spec/support/translation_matchers'

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
      expect(last_response.body).to have_message 'events.user.created'

      get '/users/me'
      expect(last_request.env['warden'].user.name).to eq user_name
    end

    it "signs out after signing in" do
      user = User.create!(
        :name  => 'Alice Smith',
        :email => 'alice@example.com',
        :password => '123456'
      )

      login_as user
      set_csrf_token 'foo'
      delete '/users/me/session', :authenticity_token => 'foo'
      follow_redirect!

      expect(last_response.status).to eq 200
      expect(last_response.body).to have_message 'events.user.signed_out'
    end
  end
end
