class AuthenticationService
  attr_reader :request
  attr_reader :scope

  def initialize(request, scope=nil)
    @request = request
    @scope   = scope
  end

  def service
    warden = request.env['warden']
    raise RuntimeError.new("Warden not found at env['warden']") unless warden
    warden
  end

  def authenticate
    service.authenticate!
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
