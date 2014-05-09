require 'active_record'

class Organization < ActiveRecord::Base
  validates :name, :presence => true
  validates :slug,
    :presence => true,
    :uniqueness => { :allow_nil => true }
end
