UpHex::Pulse.controllers :portfolios do

  get '/' do
    @portfolios_for_account=current_user.accounts.map{|account| {account.organization=>account.organization.portfolios}}
    @organizations=current_user.organizations
    render 'portfolios/list'
  end

  post '/' do
    if params[:name].empty?
      flash.now[:name] = t 'portfolios.name.empty'
      error=true
    end
    if error
      @portfolios_for_account=current_user.accounts.map{|account| {account.organization=>account.organization.portfolios}}
      @organizations=current_user.organizations
      render 'portfolios/list'
    else
      organization=current_user.organizations.select{|organization| organization.id.to_s==params[:organization]}.first
      portfolio=Portfolio.create(:name=>params[:name])
      portfolio.organization=organization
      portfolio.save
      @portfolios_for_account=current_user.accounts.map{|account| {account.organization=>account.organization.portfolios}}
      @organizations=current_user.organizations

      redirect '/portfolios'
    end
  end

end