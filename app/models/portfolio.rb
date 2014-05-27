require 'active_record'

class Portfolio < ActiveRecord::Base
  belongs_to :organization
  has_many :portfolio_streams
  has_many :streams, :through => :portfolio_streams

  validates :name, :presence => true
  validates :organization, :presence => true
end
