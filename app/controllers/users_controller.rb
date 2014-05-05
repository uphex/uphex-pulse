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

  put '/me' do
    current_user.update_attributes(params[:user])
    @user=current_user
    if @user.save
      @user.updated_at=Time.new
      @user.save!
      flash[:notice] = t 'authn.user.modified'
      redirect '/users/me'
    else
      @user.clear_password
      render 'users/show'
    end
  end

  get '/:id' do
    @user = User.find params[:id]
    error(403) unless current_ability.can? :read, @user
    render 'users/show'
  end


  post '/' do
    @user=User.create(params[:user])
    if @user.save
      @user.organizations << (Organization.create(:name => (@user.name+' Inc.')))
      @user.save!

      flash[:notice] = t 'authn.user.created'
      auth = AuthenticationService.new request
      auth.authenticate
      redirect '/users/me/dashboard'
    else
      @user.clear_password
      status 422
      render 'users/new'
    end
  end

  delete '/me/session' do
    auth = AuthenticationService.new request
    auth.logout
    flash[:notice] = I18n.t 'authn.signed_out'
    redirect '/'
  end

  get '/me/dashboard' do
    @announcements=[]
    @dashboardevents=[]
    @clients=current_user.organizations.map{|organization| organization.portfolios}.flatten
    render 'dashboard/index'
  end
end
