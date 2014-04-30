UpHex::Pulse.controllers :users do
  before do
    Ability::UserPolicy.new(current_ability).apply!
  end

  get '/new' do
    @user = User.new
    render 'users/new'
  end

  get '/me' do
    params[:name]=current_user.name
    params[:email]=current_user.email
    @user = current_user
    render 'users/show'
  end

  put '/me' do
    if User.exists?(:email=>params[:email]) and User.where(:email=>params[:email]).first.id!=current_user.id
      flash.now[:email]=t 'authn.email.taken'
      error=true
    end
    if params[:name].empty?
      flash.now[:name] = t 'authn.name.empty'
      error=true
    end
    if !params[:password].empty? and params[:password]!=params[:repassword]
      flash.now[:repassword] = t 'authn.repassword.dontmatch'
      error=true
    end
    if error
      @user = current_user
      render 'users/show'
    else
      current_user.name=params[:name]
      current_user.email=params[:email]
      if !params[:password].empty?
        current_user.password=params[:password]
      end
      current_user.updated_at=Time.new
      current_user.save!
      flash[:notice] = t 'authn.user.modified'
      redirect '/users/me'
    end

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
      @user.organizations << (Organization.create(:name => (params[:name]+' Inc.')))
      if @user.save
        #@organization=Organization.create(:name=>params[:name]+' Inc.')
        #@organization.save!
        #Account.create(:users=>@user,:@organizations=>@organization).save!

        flash[:notice] = t 'authn.user.created'
        status 201
        render 'users/show'
      else
        @user.clear_password
        status 422
        render 'users/new'
      end
      auth = AuthenticationService.new request
      auth.authenticate
      redirect '/users/me/dashboard'
    end
  end

  delete '/me/session' do
    auth = AuthenticationService.new request
    auth.logout
    flash[:notice] = I18n.t 'authn.signed_out'
    redirect '/'
  end

  get '/me/dashboard' do
    render 'dashboard/show'
  end
end
