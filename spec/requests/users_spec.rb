require 'environment_spec_helper'

describe "users" do
  context "signing up" do
    it "signs up" do
      set_csrf_token 'foo'
      post '/users',
        :authenticity_token => 'foo',
        :user_registration => {
          :user_name => 'x',
          :user_email => 'y',
          :user_password => '123456',
          :organization_name => 'w'
        }
      expect(last_response.status).to eq 201
    end
  end
end
