require 'active_record'

class Stream < ActiveRecord::Base
  belongs_to :organization
  has_many :portfolio_streams
  has_many :portfolios, :through => :portfolio_streams

  has_many :stream_credentials
  has_many :credential_tokens, :through => :stream_credentials

  validates :name, :presence => true
  validates :provider_name, :presence => true
end
