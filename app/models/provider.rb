require 'active_record'

class Provider < ActiveRecord::Base

  validates :name,
            :presence => true

  belongs_to :portfolio, :class_name => "Portfolio", :foreign_key=> "portfolios_id"
  has_many :metrics, :class_name => "Metric", :foreign_key => 'providers_id',:dependent => :destroy
end