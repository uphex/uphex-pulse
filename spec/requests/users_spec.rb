require 'environment_spec_helper'

describe "users" do
  context "signing up" do
    it "signs up" do
      set_csrf_token 'foo'
      post '/users',
        :authenticity_token => 'foo',
        :user => {
          :name => 'x',
          :email => 'y',
          :password => 'z'
        }
      expect(last_response.status).to eq 302
      expect(last_response.headers['Location']).to end_with '/users/me/dashboard'
    end
  end
end
