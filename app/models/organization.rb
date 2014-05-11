require 'active_record'

class Organization < ActiveRecord::Base
  has_many :portfolios

  validates :name, :presence => true
  validates :slug,
    :presence => true,
    :uniqueness => { :allow_nil => true }
end
