require 'active_record'
require 'bcrypt'

class User < ActiveRecord::Base
  has_many :organization_memberships
  has_many :organizations, :through => :organization_memberships

  attr_accessor :password

  validates :name,
    :presence => true

  validates :email,
    :presence => true,
    :format => { :with => /@/ }

  validates :password_hash,
    :presence => true

  validates :password,
    :presence => true,
    :length => { :minimum => 6 }

  def password=(unencrypted_password)
    unless unencrypted_password.blank?
      @password = unencrypted_password
      self.password_hash = BCrypt::Password.create(unencrypted_password)
    end
  end

  def clear_password
    @password = ''
  end
end
