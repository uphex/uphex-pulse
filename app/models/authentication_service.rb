class AuthenticationService
  attr_reader :request
  attr_reader :scope

  def initialize(request, scope=nil)
    @request = request
    @scope   = scope
  end

  def service
    request.env['warden']
  end

  def authenticate
    service.authenticate! self.scope
  end

  def authenticated?
    service.authenticated?(self.scope)
  end

  def authenticated_as?(user)
    self.authenticated? && self.user_is?(user)
  end

  def user
    service.user(scope)
  end

  def user_is?(u)
    self.user == u
  end
end
