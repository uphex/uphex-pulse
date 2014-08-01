class ImpersonateStrategy < ::Warden::Strategies::Base
  def valid?
    env['warden'].user.roles.any?{|role| role.name==='admin'}
  end

  def authenticate!
    u = User.find params['impersonate_userid']
    if u
      success! u
    else
      fail!
      throw(:warden, :message => 'authn.failure')
    end
  end

end
