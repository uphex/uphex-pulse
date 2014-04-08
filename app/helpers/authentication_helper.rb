UpHex::Pulse.helpers do
  def current_user(scope=nil)
    AuthenticationService.new(request, scope).user
  end
end
