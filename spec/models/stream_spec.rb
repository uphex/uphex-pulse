require 'spec_helper'
require 'spec/support/templates/active_record_model'
require 'app/models/stream'
require 'app/models/organization'
require 'app/models/portfolio_stream'
require 'app/models/portfolio'

describe Stream do
  context "validations" do
    validation_spec_for :presence, :name
    validation_spec_for :presence, :provider_name
    validation_spec_for :presence, :access_token
    validation_spec_for :presence, :access_token_secret
    validation_spec_for :presence, :token_type
    validation_spec_for :presence, :refresh_token
  end

  context "associations" do
    association_spec_for :belong_to, :organization
    association_spec_for :have_many, :portfolio_streams
    association_spec_for :have_many, :portfolios do |a|
      a.through(:portfolio_streams)
    end
  end
end
