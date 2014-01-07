UpHex::Pulse.controllers :sessions do
  get '/new' do
    @user = User.new
    render 'sessions/new'
  end

  post '/' do    
    @user = User.new(params['user'])
    authenticate

    puts ">>>> #{env['warden.options']}"

    if authenticated?
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
    puts ">>>>> /auth/unauthenticated failure!"

    @user = User.new(params['user'])
    redirect 'sessions/new'
  end
end
