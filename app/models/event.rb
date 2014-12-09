require 'active_record'

class Event < ActiveRecord::Base
  belongs_to :metric, :class_name => "Metric", :foreign_key=> "metrics_id"
end