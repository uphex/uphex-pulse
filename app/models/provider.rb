require 'active_record'

class Provider < ActiveRecord::Base

  validates :name,
            :presence => true

  belongs_to :portfolio, :class_name => "Portfolio", :foreign_key=> "portfolios_id"
end