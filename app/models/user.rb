require 'active_record'
require 'bcrypt'

class User < ActiveRecord::Base
  attr_accessor :password

  validates :name,
    :presence => true

  validates :email,
    :presence => true

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
end
