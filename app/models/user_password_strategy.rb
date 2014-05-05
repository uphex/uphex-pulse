class UserPasswordStrategy < ::Warden::Strategies::Base
  def valid?
    params['user']['email'] || params['user']['password']
  end

  def authenticate!
    u = User.find_by_email params['user']['email']
    m = password_matches?(u.password_hash, params['user']['password']) if u
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

end
