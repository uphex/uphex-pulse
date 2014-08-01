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
    @clients=current_user.organizations.map{|organization| organization.portfolios}.flatten.map{|portfolio|
      a=portfolio.clone
      a.alert=nil
      if portfolio.providers.blank?
        a.alert=I18n.t 'alert.no_streams'
      end
      errors=portfolio.providers.map{|provider| provider.metrics}.flatten.select{|metric| !metric.last_error_type.nil?}
      unless errors.empty?
        a.alert=I18n.t 'alert.disconnected',:stream=>errors.first.provider.provider_name.capitalize if errors.first.last_error_type==:disconnected.to_s
        a.alert=I18n.t 'alert.other',:stream=>errors.first.provider.provider_name.capitalize if errors.first.last_error_type==:other.to_s
      end
      a
    }
    @announcements=[]
    @dashboardevents=@clients.map{|portfolio| portfolio.providers}.flatten.map{|provider| provider.metrics}.flatten.map{|metric|
      metric.events.map{|event|
        transform_event(event,false)
      }
    }.flatten.sort_by{|event| event[:time]}.reverse.take(5).group_by{|e| e[:time].beginning_of_day}

    render 'dashboard/index'
  end

  get '/' do
    error(403) unless is_admin?
    @users=User.all
    render 'users/index'
  end

  post '/revoke_admin' do
    error(403) unless is_admin?
    u=User.find(params['userid'])
    u.user_roles.select{|user_role| user_role.role.name=='admin'}.each{|user_role| user_role.destroy}
    flash[:notice] = I18n.t 'authn.user.admin_revoken',username:u.name
    redirect '/users'
  end

  post '/make_admin' do
    error(403) unless is_admin?
    u=User.find(params['userid'])
    UserRole.create(:user=>u,:role=>Role.find_by_name('admin'))
    flash[:notice] = I18n.t 'authn.user.admin_granted',username:u.name
    redirect '/users'
  end
end
