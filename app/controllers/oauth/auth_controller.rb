UpHex::Pulse.controllers :auth do

  get '/:authstrategy/:provider' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    redirect AuthHelper.new(params,request,session,env['warden'].user.id).redirect_uri
  end

  get '/:authstrategy/:provider/callback' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    auth_helper=AuthHelper.new(params,request,session,env['warden'].user.id)

    begin
      providers=auth_helper.handle_callback

      if auth_helper.reauth_to.nil? and providers.size!=1
        @portfolio_id=auth_helper.portfolio.id
        @providers=providers
        render 'portfolios/add_providers'
      else
        if auth_helper.reauth_to.nil?
          flash[:notice] = I18n.t 'oauth.added',profiles:providers.map{|provider| provider[:name]}.join(','),:count=>providers.size
        else
          flash[:notice]=I18n.t 'oauth.provider.reauth.success'
        end
        redirect "portfolios/#{auth_helper.portfolio.id}"
      end

    rescue => e
      flash[:error]=e.message
      redirect "portfolios/#{auth_helper.portfolio.id}"
    end


  end

  post '/add_providers' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    if params[:provider_selected].blank?
      flash[:notice] = I18n.t 'oauth.no_providers_added'
      redirect "portfolios/#{params[:portfolio_id]}"
    else
      providers=[]
      params[:provider_selected].each{|provider_index|
        provider=Provider.create(YAML::load(params['provider_'+provider_index]))
        providers.push(provider)
        Resque.enqueue(StreamCreate,provider[:id])
      }
      flash[:notice] = I18n.t 'oauth.added',profiles:providers.map{|provider| provider[:name]}.join(','),:count=>providers.size
      redirect "portfolios/#{params[:portfolio_id]}"
    end
  end
end