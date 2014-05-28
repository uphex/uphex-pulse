UpHex::Pulse.controllers :users do
  before do
    Ability::UserPolicy.new(current_ability).apply!
  end

  get '/new' do
    @user_registration = UserRegistration.new
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
    @user_registration = UserRegistration.new params[:user_registration]

    if @user_registration.save
      @user = @user_registration.user
      flash[:notice] = t 'user.created'
      status 201
      render 'users/show'
    else
      status 422
      render 'users/new'
    end
  end
end
