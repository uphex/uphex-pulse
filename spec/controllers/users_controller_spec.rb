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
      allow_any_instance_of(app_class).to receive(:current_user).and_return user
    end

    it { expect(:get => '/users/me').to be_routable }

    it {
      get '/users/me'
      expect(last_response.status).to eq 200
    }
  end

  describe 'GET /:id' do
    let(:user) { User.new }
    before(:each) do
      allow_any_instance_of(app_class).to receive(:current_user).and_return user
    end

    it { expect(:get => '/users/arbitrary-id').to be_routable }

    it {
      allow(User).to receive(:find).with('1').and_return user
      get '/users/1'
      expect(last_response.status).to eq 200
    }

    it {
      allow(User).to receive(:find).with('2').and_return User.new
      get '/users/2'
      expect(last_response.status).to eq 403
    }
  end

  describe 'POST /' do
    before do
      set_csrf_token 'token'
    end

    it { expect(:post => '/users').to be_routable }

    it "save failure responds with failure" do
      allow_any_instance_of(UserRegistration).to receive(:save).and_return false
      post '/users', :user_registration => {}

      expect(last_response.status).to eq 422
    end

    it "save success responds with created" do
      allow_any_instance_of(UserRegistration).to receive(:save).and_return true
      allow_any_instance_of(UserPasswordStrategy).to receive(:find_matching_user).and_return User.new

      post '/users', :user_registration => {
        :user_email        => 'x@x.com',
        :user_password     => '123456',
        :user_name         => 'Alice Smith',
        :organization_name => 'z'
      }

      expect(last_response.status).to eq 201
    end
  end
end
