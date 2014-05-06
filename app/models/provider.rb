require 'active_record'

class Provider < ActiveRecord::Base

  belongs_to :portfolio, :class_name => "Portfolio", :foreign_key=> "portfolios_id"
end