require 'environment_spec_helper'
require 'app/models/user'

describe User do
  context "validations" do
    it { expect(subject).to validate_presence_of(:email) }
    it { expect(subject).to validate_presence_of(:password_hash) }
    it { expect(subject).to validate_presence_of :password }
    it { expect(subject).to validate_presence_of :password_confirmation }
    it { expect(subject).to validate_confirmation_of :password }
  end

  context "#password_hash=" do
    it "assigns to the password hash" do
      expect(subject).to receive :password_hash=
      subject.password = 'unencrypted-password'
    end
  end
end
