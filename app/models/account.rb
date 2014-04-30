require 'active_record'

class Account < ActiveRecord::Base
  belongs_to :user, :class_name => "User", :foreign_key=> "users_id"
  belongs_to :organization, :class_name => "Organization", :foreign_key=> "organizations_id"
end
