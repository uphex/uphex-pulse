class AuthHelper

  def initialize(params,request,session,userid)
    @params=params
    @request=request
    @session=session
    @userid=userid
  end

  def params
    @params
  end

  def request
    @request
  end

  def session
    @session
  end

  def userid
    @userid
  end

  def config
    @config ||= JSON.parse(File.read(File.expand_path("../../../../config/auth_config.json", __FILE__)))
  end

  def authentication_strategy
    @authentication_strategy ||= begin
      strategy_class=config[params[:authstrategy]]['providers'][params[:provider]]['instantiateClass']
      strategy_class.constantize.new
    end
  end

  def portfolio
    @portfolio ||= Portfolio.find(authentication_strategy.getPortfolioid(params,session))
  end

  def reauth_to
    @reauth_to ||= authentication_strategy.getReauthTo(params,session)
  end

  def redirect_uri
    authentication_strategy.getRedirectUri(config[params[:authstrategy]]['providers'][params[:provider]],request,session,params[:portfolioid],params[:reauth_to])
  end

  def tokens
    @tokens ||= authentication_strategy.callback(config[params[:authstrategy]]['providers'][params[:provider]],params,request,session)
  end

  def reauth_provider
    @reauth_provider ||= Provider.find(reauth_to)
  end

  def handle_reauth
    token=tokens.find{|t| authentication_strategy.profiles(t,config).any?{|profile| profile[:id]==reauth_provider[:profile_id]}}
    if token.nil?
      raise I18n.t 'oauth.provider.reauth.error'
    else
      [:access_token, :access_token_secret, :expiration_date, :refresh_token].each do |field|
        reauth_provider[field] = token[field.to_s]
      end
      reauth_provider.save!

      reauth_provider.metrics.each{|metric|
        Resque.enqueue(MetricUpdate,metric[:id])
      }

      reauth_provider
    end
  end

  def handle_provider_add
    providers=tokens.map{|token|
      authentication_strategy.profiles(token,config).map{|profile|
        Provider.new(:portfolio=>portfolio,:name=>profile[:name],:provider_name=>params[:provider],:userid=>userid,:profile_id=>profile[:id],:access_token=>token['access_token'],:access_token_secret=>token['access_token_secret'],:expiration_date=>token['expiration_date'],:token_type=>'access',:refresh_token=>token['refresh_token'],:raw_response=>authentication_strategy.raw_response)
      }
    }.flatten

    if providers.size==1
      restoring_provider=portfolio.providers.find{|provider| provider.provider_name==providers.first.provider_name && provider.profile_id==providers.first.profile_id.to_s}
      if restoring_provider.nil?
        providers.first.save!
        Resque.enqueue(StreamCreate,providers.first[:id])
      else
        raise 'oauth.provider.exists' unless restoring_provider.deleted
        restoring_provider.deleted=false
        [:access_token, :access_token_secret, :expiration_date, :refresh_token].each do |field|
          restoring_provider[field] = providers.first[field.to_s]
        end
        restoring_provider.save!
      end

    end

    providers
  end

  def handle_callback
    if reauth_to.nil?
      handle_provider_add
    else
      handle_reauth
    end

  rescue => e
    raise I18n.t e.message if e.message.starts_with? 'oauth'
    puts e.inspect, e.backtrace
    raise I18n.t 'oauth.provider.error'
  end
end