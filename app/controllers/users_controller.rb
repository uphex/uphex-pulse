UpHex::Pulse.controllers :users do
  before do
    UserAuthorizationPolicy.new(current_ability).apply!
  end

  get '/new' do
    @user_registration = UserRegistration.new(params[:user_registration])
    render 'users/new'
  end

  get '/me' do
    @user = current_user
    error(403) unless current_ability.can? :read, @user
    render 'users/show'
  end

  delete '/me/session' do
    auth = AuthenticationService.new request
    auth.unauthenticate

    flash[:notice] = I18n.t 'events.user.signed_out'
    redirect '/'
  end

  get '/:id' do
    @user = User.find params[:id]
    error(403) unless current_ability.can? :read, @user
    render 'users/show'
  end

  post '/' do
    @user_registration = UserRegistration.new params[:user_registration]

    if @user_registration.save
      @user = @user_registration.user
      flash.now[:notice] = I18n.t 'events.user.created'
      status 201

      auth = AuthenticationService.new request
      auth.authenticate

      render 'users/show'
    else
      status 422
      render 'users/new'
    end
  end

  get '/me/dashboard' do
    @portfolios = current_user.organizations.map{|organization| organization.portfolios}.flatten

    @announcements = []
    @dashboardevents = @portfolios.map{ |portfolio| portfolio.streams }.flatten.map{ |stream| stream.metrics }.flatten.map{ |metric|
      metric.events.map do |event|
        transform_event(event,false)
      end
    }.flatten.sort_by { |event| event[:time]}.reverse.take(5).group_by{|e| e[:time].beginning_of_day }

    render 'dashboard/index'
  end
end
