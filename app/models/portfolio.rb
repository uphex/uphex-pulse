require 'active_record'

class Portfolio < ActiveRecord::Base
  attr_accessor :alert
  validates :name,
            :presence => true, uniqueness: true

  belongs_to :organization, :class_name => "Organization", :foreign_key=> "organizations_id"
end
