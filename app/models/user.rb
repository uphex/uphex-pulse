require 'active_record'
require 'bcrypt'

class User < ActiveRecord::Base
  attr_accessor :password

  validates :name,
    :presence => true

  validates :email,
    :presence => true, uniqueness: true

  validates :password_hash,
    :presence => true

  def password=(unencrypted_password)
    unless unencrypted_password.blank?
      @password = unencrypted_password
      self.password_hash = BCrypt::Password.create(unencrypted_password)
    end
  end

  def clear_password
    @password = ''
  end

  has_many :accounts, :class_name => "Account", :foreign_key => 'users_id'
  has_many :organizations, through: :accounts, source: :organization

  has_many :user_roles, :class_name => "UserRole", :foreign_key => 'users_id'

  def roles
    roles=user_roles.map{|user_role| user_role.role}
    if !roles.any?{|role| role.name=='user'}
      roles<< Role.find_by_name('user')
    end
    roles
  end
end
