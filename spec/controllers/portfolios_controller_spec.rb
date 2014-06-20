require 'spec/environment_spec_helper'

describe 'PortfoliosController' do
  let(:user) { User.new }
  before(:each) do
    allow_any_instance_of(app_class).to receive(:current_user).and_return user
  end

  describe 'GET /new' do
    it { expect(:get => '/portfolios/new').to be_routable }

    it {
      get '/portfolios/new'
      expect(last_response.status).to eq 200
    }
  end

  describe 'GET /:id' do
    let(:portfolio) { Portfolio.new }

    it { expect(:get => '/portfolios/arbitrary-id').to be_routable }

    it {
      Portfolio.stub(:find).with('arbitrary').and_return portfolio
      get '/portfolios/arbitrary'
      expect(last_response.status).to eq 200
    }
  end
end
