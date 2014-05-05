require 'active_record'

class Portfolio < ActiveRecord::Base

  validates :name,
            :presence => true, uniqueness: true

  belongs_to :organization, :class_name => "Organization", :foreign_key=> "organizations_id"
end
