UpHex::Pulse.controllers :clients do
  before do
    Ability::PortfolioPolicy.new(current_ability).apply!
  end

  get '/:id' do

    @client=Portfolio.find(params[:id])
    error(403) unless current_ability.can? :read, @client

    metrics=@client.providers.map{|provider|
      provider.metrics
    }.flatten

    @clientevents=metrics.map{|metric|
      metric.events.map{|event|
        transform_event(event,false)
      }
    }.flatten.sort_by{|event| event[:time]}.reverse.take(5).group_by{|e| e[:time].beginning_of_day}

    @clientstreams=metrics.map{|metric|
      unless metric.observations.empty?
        sparkline=SparklineNormalizer.new.normalize(metric.observations.where('index>=:time',{:time=>DateTime.now - 30.days}).sort_by(&:index)).map{|collection|
                collection[:value].round
        }
        if sparkline.size<2
          sparkline=nil
        end
      end
      unless sparkline.nil?
        rangestart=sparkline.min
        rangeend=sparkline.max
        average=(sparkline.last(7).reduce(:+).to_f / sparkline.last(7).size).round(0)
      end

      {:categorytype=>metric.provider.name,:categoryicon=>icons[metric.provider.provider_name.to_sym],:id=>metric.provider.id,:metricname=>metric.name,:average=>average,:rangestart=>rangestart,:rangeend=>rangeend,:sparkline=>sparkline}
    }.group_by{|s| [s[:categorytype],s[:categoryicon],s[:id]]}
    render 'clients/show'
  end
end