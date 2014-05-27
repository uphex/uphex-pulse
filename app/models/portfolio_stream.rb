require 'active_record'

class PortfolioStream < ActiveRecord::Base
  belongs_to :portfolio
  belongs_to :stream
end
