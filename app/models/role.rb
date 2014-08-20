require 'active_record'

class Role < ActiveRecord::Base

  validates :name,
            :presence => true
end
