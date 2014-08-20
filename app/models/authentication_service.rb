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

  def authenticate(strategy=nil)
    if strategy.nil?
      service.authenticate!(:scope=>@scope)
    else
      service.authenticate!(strategy,:scope=>@scope)
    end
  end

  def authenticated?
    service.authenticated?(self.scope)
  end

  def authenticated_as?(user)
    self.authenticated? && self.user_is?(user)
  end

  def user
    if service.user(:impersonate).nil?
      service.user(@scope)
    else
      service.user(:impersonate)
    end
  end

  def user_is?(u)
    self.user == u
  end

  def logout
    if @scope.nil?
      service.logout
    else
      service.logout(@scope)
    end
  end
end
