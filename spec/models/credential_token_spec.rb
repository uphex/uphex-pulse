require 'spec_helper'
require 'spec/support/templates/active_record_model'
require 'app/models/stream'
require 'app/models/credential_token'

describe CredentialToken do
  context "validations" do
    validation_spec_for :presence, :token
    validation_spec_for :presence, :metadata
  end
end
