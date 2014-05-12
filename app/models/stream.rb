require 'active_record'

class Stream < ActiveRecord::Base
  belongs_to :organization

  validates :name, :presence => true
  validates :provider_name, :presence => true
  validates :access_token, :presence => true
  validates :access_token_secret, :presence => true
  validates :token_type, :presence => true
  validates :refresh_token, :presence => true
end
