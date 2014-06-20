UpHex::Pulse.controllers :portfolios do
  before do
    PortfolioAuthorizationPolicy.new(current_ability).apply!
  end

  get '/new' do
    @portfolio = Portfolio.new(:organization => current_user.organizations.first)
    render 'portfolios/new'
  end

  post '/' do
    @portfolio = Portfolio.new params[:portfolio]

    if @portfolio.save
      flash.now[:notice] = I18n.t 'events.portfolio.created'

      status 201
      render 'portfolios/show'
    else
      status 422
      render 'portfolios/new'
    end
  end

  get '/:id' do
    @portfolio = Portfolio.find params[:id]
    render 'portfolios/show'
  end
end
