module AuthenticationHelper
  def current_user(scope=nil)
    @current_user ||= AuthenticationService.new(request, scope).user
  end
end

UpHex::Pulse.helpers AuthenticationHelper
