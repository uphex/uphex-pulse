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

    redirect @authenticationStrategy.getRedirectUri(@config[params[:authstrategy]]['providers'][params[:provider]],request,session,params[:portfolioid],params[:reauth_to])
  end

  get '/:authstrategy/:provider/callback' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    read_config


    portfolio=Portfolio.find(@authenticationStrategy.getPortfolioid(params,session))
    reauth_to= @authenticationStrategy.getReauthTo(params,session)

    begin
      tokens=@authenticationStrategy.callback(@config[params[:authstrategy]]['providers'][params[:provider]],params,request,session)
      puts tokens

      if reauth_to.nil?

        @providers=[]

        tokens.each{|token|
          @authenticationStrategy.profiles(token,@config).each{|profile|
            provider=Provider.new(:portfolio=>portfolio,:name=>profile[:name],:provider_name=>params[:provider],:userid=>env['warden'].user.id,:profile_id=>profile[:id],:access_token=>token['access_token'],:access_token_secret=>token['access_token_secret'],:expiration_date=>token['expiration_date'],:token_type=>'access',:refresh_token=>token['refresh_token'],:raw_response=>'TODO')
            @providers.push(provider)
          }
        }

        if @providers.size==1
          @providers.first.save!
          Resque.enqueue(StreamCreate,@providers.first[:id])
          flash[:notice] = I18n.t 'oauth.added',profiles:@providers.map{|provider| provider[:name]}.join(','),:count=>@providers.size

          redirect "portfolios/#{portfolio.id}"
        else
          @portfolio_id=portfolio.id

          render 'portfolios/add_providers'
        end
      else
        provider=Provider.find(reauth_to)
        token=tokens.find{|t| @authenticationStrategy.profiles(t,@config).any?{|profile| profile[:id]==provider[:profile_id]}}
        if token.nil?
          flash[:error]=I18n.t 'oauth.provider.reauth.error'
          redirect "portfolios/#{portfolio.id}"
        else
          provider[:access_token]=token['access_token']
          provider[:access_token_secret]=token['access_token_secret']
          provider[:expiration_date]=token['expiration_date']
          provider[:refresh_token]=token['refresh_token']
          provider.save!

          provider.metrics.each{|metric|
            Resque.enqueue(MetricUpdate,metric[:id])
          }

          flash[:error]=I18n.t 'oauth.provider.reauth.success'
          redirect "portfolios/#{portfolio.id}"
        end
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