UpHex::Pulse.controllers :portfolios do

  get '/' do
    @portfolios_for_account=current_user.accounts.map{|account| {account.organization=>account.organization.portfolios}}
    @organizations=current_user.organizations
    @portfolio=Portfolio.new
    render 'portfolios/list'
  end

  post '/' do
    params[:portfolio][:organization]=Organization.find(params[:portfolio][:organization])
    @portfolio=Portfolio.create(params[:portfolio])
    if @portfolio.save
      redirect '/portfolios'
    else
      @portfolios_for_account=current_user.accounts.map{|account| {account.organization=>account.organization.portfolios}}
      @organizations=current_user.organizations
      render 'portfolios/list'
    end


    end

end