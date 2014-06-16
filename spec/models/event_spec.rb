require 'spec_helper'
require 'spec/support/templates/active_record_model'
require 'app/models/event'

describe Event do
  context "validations" do
    validation_spec_for :presence, :kind
    validation_spec_for :presence, :occurred_at
  end

  context "associations" do
    association_spec_for :belong_to, :targetable
  end
end
