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
      flash[:notice] = I18n.t 'events.user.signed_in'
      redirect '/'
    else
      logger.info "sessions#/: authentication failed"
      redirect 'sessions/new'
    end
  end

  post '/auth/unauthenticated' do
    flash[:notice] = I18n.t 'events.authentication.failure'
    logger.debug "sessions#auth/unauthenticated: failure!"

    @user = User.new(params['user'])
    redirect 'sessions/new'
  end
end
