UpHex::Pulse.helpers do
  def current_user(scope=nil)
    @current_user ||= AuthenticationService.new(request, scope).user
  end
end
