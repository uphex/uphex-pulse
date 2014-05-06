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

    tokens=@authenticationStrategy.callback(@config[params[:authstrategy]]['providers'][params[:provider]],params,request,session)
    puts tokens

    portfolio=Portfolio.find(@authenticationStrategy.getPortfolioid(params,session))

    profile_names=[]

    tokens.each{|token|
      @provider=Provider.create(:portfolio=>portfolio,:name=>params[:provider],:provider_name=>params[:provider],:userid=>env['warden'].user.id,:access_token=>token['access_token'],:access_token_secret=>token['access_token_secret'],:expiration_date=>token['expiration_date'],:token_type=>'access',:refresh_token=>token['refresh_token'],:raw_response=>'TODO')
      profile_names.push(@authenticationStrategy.profile_names(@provider,@config))
    }

    flash[:notice] = I18n.t 'oauth.added',profiles:profile_names.flatten.join(','),:count=>profile_names.flatten.size

    redirect "portfolios/#{portfolio.id}"
  end
end