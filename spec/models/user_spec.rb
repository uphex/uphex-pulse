require 'spec_helper'
require 'spec/support/templates/active_record_model'
require 'app/models/user'

describe User do
  context "validations" do
    it { expect(subject).to validate_presence_of(:name) }
    it { expect(subject).to validate_presence_of(:email) }
    it { expect(subject).to validate_presence_of(:password_hash) }
    it { expect(subject).to validate_presence_of :password }
  end

  context "#password_hash=" do
    it "assigns to the password hash" do
      expect(subject).to receive :password_hash=
      subject.password = 'unencrypted-password'
    end
  end
end
