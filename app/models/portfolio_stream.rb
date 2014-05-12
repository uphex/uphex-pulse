require 'active_record'
require 'app/models/portfolio'
require 'app/models/stream'

class PortfolioStream < ActiveRecord::Base
  belongs_to :portfolio
  belongs_to :stream
end
