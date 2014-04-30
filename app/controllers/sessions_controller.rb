UpHex::Pulse.controllers :sessions do
  get '/new' do
    @user = User.new
    render 'sessions/new'
  end

  post '/' do
    @user = User.new(params['user'])
    auth = AuthenticationService.new request
    auth.authenticate

    if auth.authenticated?
      logger.info "sessions#/: with #{auth.user}"
      flash[:notice] = I18n.t 'authn.signed_in'
      redirect '/users/me/dashboard'
    else
      logger.info "sessions#/: authentication failed"
      redirect 'sessions/new'
    end
  end

  post '/auth/unauthenticated' do
    flash[:error] = I18n.t 'authn.failure'
    logger.debug "sessions#auth/unauthenticated: failure!"

    @user = User.new(params['user'])
    redirect 'sessions/new'
  end
end
