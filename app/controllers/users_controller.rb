UpHex::Pulse.controllers :users do
  before do
    Ability::UserPolicy.new(current_ability).apply!
  end

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
    error(403) unless current_ability.can? :read, @user
    render 'users/show'
  end


  post '/' do
    if User.exists?(:email=>params[:email])
      flash.now[:email]=t 'authn.email.taken'
      error=true
    end
    if params[:password].empty?
      flash.now[:password] = t 'authn.password.empty'
      error=true
    end
    if params[:name].empty?
      flash.now[:name] = t 'authn.name.empty'
      error=true
    end
    if params[:password]!=params[:repassword]
      flash.now[:repassword] = t 'authn.repassword.dontmatch'
      error=true
    end

    if error
      render '/users/new'
    else
      @user=User.create(:name=>params[:name],:email=>params[:email],:password=>params[:password])
      if @user.save
        flash[:notice] = t 'user.created'
        status 201
        render 'users/show'
      else
        @user.clear_password
        status 422
        render 'users/new'
      end
      auth = AuthenticationService.new request
      auth.authenticate
      redirect '/'
    end
  end
end
