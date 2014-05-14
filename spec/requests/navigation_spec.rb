require 'environment_spec_helper'

describe "page navigation request" do
  context "when not logged in" do
    it "contains sign in and sign up links" do
      get '/'
      expect(last_response.body).to include "sign up"
      expect(last_response.body).to include "sign in"
    end
  end

  context "when logged in" do
    it "contains user name links" do
      app_class.any_instance.stub :current_user => User.new(:name => 'Bobby Tables')
      get '/'
      expect(last_response.body).to include 'Bobby Tables'
    end
  end
end
