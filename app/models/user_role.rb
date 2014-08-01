require 'active_record'

class UserRole < ActiveRecord::Base
  belongs_to :user, :class_name => "User", :foreign_key=> "users_id"
  belongs_to :role, :class_name => "Role", :foreign_key=> "roles_id"
end
