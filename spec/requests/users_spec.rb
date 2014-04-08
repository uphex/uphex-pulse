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
      expect(last_response.status).to eq 201
    end
  end
end
