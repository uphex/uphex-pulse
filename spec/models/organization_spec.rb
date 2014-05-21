require 'spec_helper'
require 'spec/support/templates/active_record_model'
require 'app/models/organization'

describe Organization do
  context "validations" do
    validation_spec_for :presence, :name
    validation_spec_for :presence, :slug
    validation_spec_for :uniqueness, :slug
  end

  context "associations" do
    association_spec_for :have_many, :portfolios
  end
end
