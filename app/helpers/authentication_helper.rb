module AuthenticationHelper
  def current_user(scope=nil)
    AuthenticationService.new(request, scope).user
  end
end

UpHex::Pulse.helpers AuthenticationHelper
