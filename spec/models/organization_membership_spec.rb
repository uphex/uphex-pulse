require 'spec_helper'
require 'spec/support/templates/active_record_model'
require 'app/models/organization_membership'

describe OrganizationMembership do
  context "validations" do
    validation_spec_for :presence, :user
    validation_spec_for :presence, :organization
  end
end
