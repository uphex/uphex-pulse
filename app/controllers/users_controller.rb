UpHex::Pulse.controllers :users do
  get '/new' do
    @user = User.new
    render 'users/new'
  end

  post '/' do
    @user = User.new params['user']

    if @user.save
      flash[:notice] = t 'user.created'
      redirect '/'
    else
      @user.clear_password
      status 422
      render 'users/new'
    end
  end
end
