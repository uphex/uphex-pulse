require 'app/models/user'
require 'spec_helper'
require 'spec/support/templates/active_record_model'
require 'app/models/user'
require 'app/models/organization'
require 'app/models/organization_membership'
require 'app/models/user_registration'

describe UserRegistration do
  it "saves everything" do
    attributes = {
      :user_name => 'Alice Smith',
      :user_email => 'alice@smith.org',
      :user_password => '123456',
      :organization_name => 'AliceCorp'
    }

    o = described_class.new(attributes)
    expect(o.valid?).to be true
  end
end
