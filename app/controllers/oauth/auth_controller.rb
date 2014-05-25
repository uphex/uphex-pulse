UpHex::Pulse.controllers :auth do

  define_method :read_config do
    @config = JSON.parse(File.read(File.expand_path("../../../../config/auth_config.json", __FILE__)))

    case @config[params[:authstrategy]]['providers'][params[:provider]]['instantiateClass']
      when 'GoogleAuthenticationStrategy'
        @authenticationStrategy=GoogleAuthenticationStrategy.new
      when 'FacebookAuthenticationStrategy'
        @authenticationStrategy=FacebookAuthenticationStrategy.new
      when 'MailchimpAuthenticationStrategy'
        @authenticationStrategy=MailchimpAuthenticationStrategy.new
      when 'TwitterAuthenticationStrategy'
        @authenticationStrategy=TwitterAuthenticationStrategy.new
    end
  end

  get '/:authstrategy/:provider' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    read_config

    redirect @authenticationStrategy.getRedirectUri(@config[params[:authstrategy]]['providers'][params[:provider]],request,session,params[:portfolioid])
  end

  get '/:authstrategy/:provider/callback' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    read_config

    portfolio=Portfolio.find(@authenticationStrategy.getPortfolioid(params,session))

    begin
      tokens=@authenticationStrategy.callback(@config[params[:authstrategy]]['providers'][params[:provider]],params,request,session)
      puts tokens

      @providers=[]

      tokens.each{|token|
        @authenticationStrategy.profiles(token,@config).each{|profile|
          provider=Provider.new(:portfolio=>portfolio,:name=>profile[:name],:provider_name=>params[:provider],:userid=>env['warden'].user.id,:profile_id=>profile[:id],:access_token=>token['access_token'],:access_token_secret=>token['access_token_secret'],:expiration_date=>token['expiration_date'],:token_type=>'access',:refresh_token=>token['refresh_token'],:raw_response=>'TODO')
          @providers.push(provider)
        }
      }

      if @providers.size==1
        @providers.first.save!
        require File.expand_path("../../../jobs/StreamCreate.rb", __FILE__)
        Resque.enqueue(StreamCreate,@providers.first[:id])
        flash[:notice] = I18n.t 'oauth.added',profiles:@providers.map{|provider| provider[:name]}.join(','),:count=>@providers.size

        redirect "portfolios/#{portfolio.id}"
      else
        @portfolio_id=portfolio.id

        render 'portfolios/add_providers'
      end

    rescue => e
      puts e.inspect, e.backtrace
      flash[:error]=I18n.t 'oauth.provider.error'
      redirect "portfolios/#{portfolio.id}"
    end




  end

  post '/add_providers' do
    puts params[:provider_selected]
    if params[:provider_selected].blank?
      flash[:notice] = I18n.t 'oauth.no_providers_added'
      redirect "portfolios/#{params[:portfolio_id]}"
    else
      require File.expand_path("../../../jobs/StreamCreate.rb", __FILE__)
      providers=[]
      params[:provider_selected].each{|provider_index|
        puts params['provider_'+provider_index]
        provider=Provider.create(YAML::load(params['provider_'+provider_index]))
        puts provider
        providers.push(provider)
        Resque.enqueue(StreamCreate,provider[:id])
      }
      flash[:notice] = I18n.t 'oauth.added',profiles:providers.map{|provider| provider[:name]}.join(','),:count=>providers.size
      redirect "portfolios/#{params[:portfolio_id]}"
    end
  end
end