UpHex::Pulse.controllers :users do
  get '/new' do
    @user = User.new
    render 'users/new'
  end

  get '/me' do
    @user = current_user
    render 'users/show'
  end

  get '/:id' do
    @user = User.find params[:id]
    render 'users/show'
  end

  post '/' do
    @user = User.new params[:user]

    if @user.save
      flash[:notice] = t 'user.created'
      status 201
      render 'users/show'
    else
      @user.clear_password
      status 422
      render 'users/new'
    end
  end
end
