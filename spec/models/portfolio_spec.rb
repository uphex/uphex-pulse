require 'spec_helper'
require 'spec/support/templates/active_record_model'
require 'app/models/portfolio_stream'
require 'app/models/stream'
require 'app/models/portfolio'

describe Portfolio do
  context "validations" do
    validation_spec_for :presence, :organization
    validation_spec_for :presence, :name
  end

  context "associations" do
    association_spec_for :have_many, :portfolio_streams
    association_spec_for :have_many, :streams do |a|
      a.through(:portfolio_streams)
    end
  end
end
