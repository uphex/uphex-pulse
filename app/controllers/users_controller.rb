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
