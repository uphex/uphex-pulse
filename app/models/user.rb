require 'active_record'

class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessor :password_confirmation

  validates :name,
    :presence => true

  validates :email,
    :presence => true

  validates :password_hash,
    :presence => true

  validates :password,
    :presence => true,
    :confirmation => true

  validates :password_confirmation,
    :presence => true

  def password=(unencrypted_password)
    unless unencrypted_password.blank?
      @password = unencrypted_password
      self.password_hash = BCrypt::Password.create(unencrypted_password)
    end
  end

  def password_confirmation=(unencrypted_password)
    @password_confirmation = unencrypted_password
  end
end
