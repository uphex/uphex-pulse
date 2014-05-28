UpHex::Pulse.controllers :events do
  before do
    Ability::ProviderPolicy.new(current_ability).apply!
  end

  get '/' do
    @clients=current_user.organizations.map{|organization| organization.portfolios}.flatten
    if params[:portfolioid]
      @client=@clients.find{|portfolio| portfolio.id.to_s==params[:portfolioid]}
      @clients=[@client]
    end
    @announcements=[]
    @allevents=@clients.map{|portfolio| portfolio.providers}.flatten.map{|provider| provider.metrics}.flatten.map{|metric|
      metric.events.map{|event|
        transform_event(event,false)
      }
    }.flatten.sort_by{|event| event[:time]}.reverse.group_by{|e| e[:time].beginning_of_day}

    render 'events/index'
  end

end
