UpHex::Pulse.controllers :portfolios do

  before do
    Ability::PortfolioPolicy.new(current_ability).apply!
  end

  get '/' do
    @organizations=current_user.organizations
    @portfolio=Portfolio.new
    render 'portfolios/new'
  end

  post '/' do
    params[:portfolio][:organization]=Organization.find(params[:portfolio][:organization])
    Ability::OrganizationPolicy.new(current_ability).apply!
    error(403) unless current_ability.can? :read, params[:portfolio][:organization]
    @portfolio=Portfolio.create(params[:portfolio])
    if @portfolio.save
      flash[:notice] = t 'authn.portfolio.created'
      redirect '/users/me/dashboard'
    else
      @existing_portfolio=current_user.accounts.map{|account| account.organization.portfolios}.flatten.find{|portfolio| portfolio.name===@portfolio[:name]}
      if @existing_portfolio.nil?
        @portfolios_for_account=current_user.accounts.map{|account| {account.organization=>account.organization.portfolios}}
        @organizations=current_user.organizations
        render 'portfolios/new'
      else
        render 'portfolios/restore'
      end
    end
  end

  get '/:id' do
    @portfolio=Portfolio.find(params[:id])
    error(403) unless current_ability.can? :read, @portfolio
    render 'portfolios/show'
  end

  put '/:id' do
    @portfolio=Portfolio.find(params[:id])
    error(403) unless current_ability.can? :update, @portfolio
    @portfolio.update_attributes(params[:portfolio])
    if @portfolio.save
      @portfolio.updated_at=Time.new
      @portfolio.save!
      flash[:notice] = t 'portfolio.modified'
      redirect "/portfolios/#{params[:id]}"
    else
      render 'portfolios/show'
    end
  end

  delete '/:id' do
    portfolio=Portfolio.find(params[:id])
    error(403) unless current_ability.can? :delete, portfolio
    portfolio.deleted=true
    portfolio.save!
    flash[:notice] = t 'portfolio.deleted'
    redirect '/users/me/dashboard'
  end

  post '/restore/:id' do
    portfolio=Portfolio.find(params[:id])
    error(403) unless current_ability.can? :restore, portfolio
    portfolio.deleted=false
    portfolio.save!
    flash[:notice] = t 'portfolio.restored',portfolio:portfolio.name
    redirect '/users/me/dashboard'
  end



end