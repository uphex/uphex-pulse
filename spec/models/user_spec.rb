require 'spec_helper'
require 'spec/support/templates/active_record_model'
require 'app/models/organization'
require 'app/models/organization_membership'
require 'app/models/user'

describe User do
  context "validations" do
    validation_spec_for :presence, :name
    validation_spec_for :presence, :email
    validation_spec_for :presence, :password_hash
    validation_spec_for :presence, :password
  end

  context "associations" do
    association_spec_for :have_many, :organization_memberships
    association_spec_for :have_many, :organizations do |a|
      a.through(:organization_memberships)
    end
  end

  context "#password_hash=" do
    it "assigns to the password hash" do
      expect(subject).to receive :password_hash=
      subject.password = 'unencrypted-password'
    end
  end
end
