require 'active_record'

class OrganizationMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :organization

  validates :user,
    :presence => true,
    :uniqueness => { :scope => :organization_id }

  validates :organization,
    :presence => true,
    :uniqueness => { :scope => :user_id }
end
