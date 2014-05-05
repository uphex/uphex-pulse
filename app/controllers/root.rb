UpHex::Pulse.controllers do
  get "/" do
    if current_user.nil?
      render "index"
    else
      redirect '/users/me/dashboard'
    end
  end
end
