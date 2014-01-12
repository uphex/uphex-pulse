require 'spec/environment_spec_helper'

describe 'UsersController' do
  describe 'GET /new' do
    it { expect(:get => '/users/new').to be_routable }

    it {
      get '/users/new'
      expect(last_response.status).to eq 200
    }
  end

  describe 'POST /' do
    before do
      set_csrf_token 'token'
    end

    it { expect(:post => '/users').to be_routable }

    it "save failure responds with failure" do
      User.any_instance.stub(:save => false)
      post '/users', :user => {}

      expect(last_response.status).to eq 422
    end

    it "save success responds with redirect" do
      User.any_instance.stub(:save => true)
      post '/users', :user => {}

      expect(last_response.status).to eq 302
    end
  end
end
