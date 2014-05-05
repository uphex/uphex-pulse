require 'active_record'
require 'bcrypt'

class User < ActiveRecord::Base
  attr_accessor :password, :repassword

  validate :repassword_must_match_password_if_password_is_not_blank,
           :password_cant_be_blank_if_user_does_not_exists

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
    self.repassword=''
  end

  def repassword_must_match_password_if_password_is_not_blank
    if !@password.blank? and @password!=repassword
      errors.add(:repassword, 'don\'t match')
    end
  end

  def password_cant_be_blank_if_user_does_not_exists
    if password_hash.nil? and @password.blank?
      errors.add(:password, 'can\'t be blank')
    end
  end

  has_many :accounts, :class_name => "Account", :foreign_key => 'users_id'
  has_many :organizations, through: :accounts, source: :organization
end
