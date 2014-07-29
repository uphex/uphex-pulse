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
    @in_config ||= JSON.parse(File.read(File.expand_path("../../../../config/auth_config.json", __FILE__)))
  end

  def authentication_strategy
    @in_auth_strategy ||= case config[params[:authstrategy]]['providers'][params[:provider]]['instantiateClass']
      when 'GoogleAuthenticationStrategy'
        GoogleAuthenticationStrategy.new
      when 'FacebookAuthenticationStrategy'
        FacebookAuthenticationStrategy.new
      when 'MailchimpAuthenticationStrategy'
        MailchimpAuthenticationStrategy.new
      when 'TwitterAuthenticationStrategy'
        TwitterAuthenticationStrategy.new
      else
        raise
    end
  end

  def portfolio
    @in_portfolio ||= Portfolio.find(authentication_strategy.getPortfolioid(params,session))
  end

  def reauth_to
    @in_reauth_to ||= authentication_strategy.getReauthTo(params,session)
  end

  def redirect_uri
    authentication_strategy.getRedirectUri(config[params[:authstrategy]]['providers'][params[:provider]],request,session,params[:portfolioid],params[:reauth_to])
  end

  def tokens
    @in_tokens ||= authentication_strategy.callback(config[params[:authstrategy]]['providers'][params[:provider]],params,request,session)
  end

  def handle_callback
    begin
      if reauth_to.nil?

        providers=tokens.map{|token|
          authentication_strategy.profiles(token,config).map{|profile|
            Provider.new(:portfolio=>portfolio,:name=>profile[:name],:provider_name=>params[:provider],:userid=>userid,:profile_id=>profile[:id],:access_token=>token['access_token'],:access_token_secret=>token['access_token_secret'],:expiration_date=>token['expiration_date'],:token_type=>'access',:refresh_token=>token['refresh_token'],:raw_response=>authentication_strategy.raw_response)
          }
        }.flatten

        if providers.size==1
          providers.first.save!
          Resque.enqueue(StreamCreate,providers.first[:id])
        end

        providers

      else
        provider=Provider.find(reauth_to)
        token=tokens.find{|t| authentication_strategy.profiles(t,config).any?{|profile| profile[:id]==provider[:profile_id]}}
        if token.nil?
          raise I18n.t 'oauth.provider.reauth.error'
        else
          provider[:access_token]=token['access_token']
          provider[:access_token_secret]=token['access_token_secret']
          provider[:expiration_date]=token['expiration_date']
          provider[:refresh_token]=token['refresh_token']
          provider.save!

          provider.metrics.each{|metric|
            Resque.enqueue(MetricUpdate,metric[:id])
          }

          provider
        end
      end
    rescue => e
      puts e.inspect, e.backtrace
      raise I18n.t 'oauth.provider.error'
    end
  end
end