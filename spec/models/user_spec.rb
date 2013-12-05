require 'environment_spec_helper'
require 'app/models/user'

describe User do
  context "validations" do
    it { expect(subject).to validate_presence_of(:email) }
    it { expect(subject).to validate_presence_of(:password_hash) }
  end
end
