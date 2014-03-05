UpHex::Pulse.controllers :sessions do
  get '/new' do
    @user = User.new
    render 'sessions/new'
  end

  post '/' do    
    @user = User.new(params['user'])
    auth = AuthenticationService.new request
    auth.authenticate

    logger.debug "new authn request: #{env['warden.options']}"

    if auth.authenticated?
      flash[:notice] = I18n.t 'authn.signed_in'
      redirect '/'
    else
      raise
      redirect 'sessions/new'
    end
  end

  get '/auth/logout' do
    logout
    flash[:notice] = I18n.t 'authn.signed_out'
    redirect '/'
  end

  post '/auth/unauthenticated' do
    flash[:notice] = I18n.t 'authn.failure'
    logger.debug "sessions#auth/unauthenticated failure!"

    @user = User.new(params['user'])
    redirect 'sessions/new'
  end
end
