require 'active_record'

class Metric < ActiveRecord::Base
  belongs_to :provider, :class_name => "Provider", :foreign_key=> "providers_id"
end