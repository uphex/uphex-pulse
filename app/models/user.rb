require 'active_record'

class User < ActiveRecord::Base
  validates :email, :presence => true
  validates :password_hash, :presence => true
end
