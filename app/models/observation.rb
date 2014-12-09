require 'active_record'

class Observation < ActiveRecord::Base
  belongs_to :metric, :class_name => "Metric", :foreign_key=> "metrics_id"
end