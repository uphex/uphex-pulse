require 'environment_spec_helper'

describe "page navigation request" do
  context "when not logged in" do
    it "contains sign in link" do
      get '/'
      expect(last_response.body).to include "sign up"
    end
  end
end
