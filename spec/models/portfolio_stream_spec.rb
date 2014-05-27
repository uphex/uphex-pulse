require 'spec_helper'
require 'spec/support/templates/active_record_model'
require 'app/models/portfolio'
require 'app/models/stream'
require 'app/models/portfolio_stream'

describe PortfolioStream do
  context "associations" do
    association_spec_for :belong_to, :portfolio
    association_spec_for :belong_to, :stream
  end
end
