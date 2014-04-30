require 'active_record'

class Organization < ActiveRecord::Base

  validates :name,
            :presence => true

  has_many :accounts, :class_name => "Account", :foreign_key => 'organizations_id'
  has_many :users, through: :accounts, source: :user
end
