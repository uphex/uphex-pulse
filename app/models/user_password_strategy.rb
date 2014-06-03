class UserPasswordStrategy < ::Warden::Strategies::Base
  def valid?
    user_params['email'] || user_params['password']
  end

  def authenticate!
    user = find_matching_user
    if user
      success! user
    else
      fail!
      throw(:warden, :message => 'authn.failure')
    end
  end

  def find_matching_user
    u = User.find_by_email user_params['email']
    supplied_password = user_params['password']
    password_matches  = password_matches?(u.password_hash, supplied_password) if u

    u if password_matches
  end

  def password_matches?(expected, supplied)
    BCrypt::Password.new(expected) == supplied
  end

  private
  def user_params
    @hash ||= make_user_params
  end

  def make_user_params
    user_hash = params['user'] || params['user_registration'] || {}

    {}.tap do |hash|
      hash['email']    = user_hash['email']    || user_hash['user_email']
      hash['password'] = user_hash['password'] || user_hash['user_password']
    end
  end
end
