require 'spec/environment_spec_helper'

describe 'UsersController' do
  describe 'GET /new' do
    it { expect(:get => '/users/new').to be_routable }

    it {
      get '/users/new'
      expect(last_response.status).to eq 200
    }
  end

  describe 'GET /me' do
    let(:user) { User.new }
    before(:each) do
      app_class.any_instance.stub(:current_user).and_return user
    end

    it { expect(:get => '/users/me').to be_routable }

    it {
      get '/users/me'
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

    it "save success responds with created" do
      User.any_instance.stub(:save => true)
      post '/users', :user => {}

      expect(last_response.status).to eq 201
    end
  end
end
