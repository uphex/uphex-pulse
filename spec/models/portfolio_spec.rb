require 'spec_helper'
require 'spec/support/templates/active_record_model'
require 'app/models/portfolio'

describe Portfolio do
  context "validations" do
    validation_spec_for :presence, :organization
    validation_spec_for :presence, :name
  end
end
