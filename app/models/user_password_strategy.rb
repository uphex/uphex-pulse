class UserPasswordStrategy < ::Warden::Strategies::Base
  def valid?
    user_params['email'] || user_params['password']
  end

  def authenticate!
    u = User.find_by_email user_params['email']
    m = password_matches?(u.password_hash, user_params['password']) if u
    if u && m
      success! u
    else
      fail!
      throw(:warden, :message => 'authn.failure')
    end
  end

  def password_matches?(expected, supplied)
    BCrypt::Password.new(expected) == supplied
  end

  private
  def user_params
    if params['user']
      params['user']
    else
      params
    end
  end
end
