require 'active_record'

class Metric < ActiveRecord::Base
  belongs_to :provider, :class_name => "Provider", :foreign_key=> "providers_id"
  has_many :observations, :class_name => "Observation", :foreign_key => 'metrics_id'
end