require 'spec_helper'
require 'spec/support/templates/active_record_model'
require 'app/models/user'
require 'app/models/organization'
require 'app/models/organization_membership'

describe OrganizationMembership do
  context "validations" do
    validation_spec_for :presence, :user
    validation_spec_for :presence, :organization

    it "requires uniqueness on :user_id and :organization_id" do
      user = User.create!(:name => 'a', :email => 'b@b.com', :password => 'cccccc')
      org  = Organization.create!(:name => 'a')
      make_membership = ->{ OrganizationMembership.create!(:user => user, :organization => org) }

      make_membership.call
      expect { make_membership.call }.to raise_error ActiveRecord::RecordInvalid
    end
  end
end
