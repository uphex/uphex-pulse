UpHex::Pulse.controllers :clients do
  before do
    Ability::PortfolioPolicy.new(current_ability).apply!
  end

  get '/:id' do

    @client=Portfolio.find(params[:id])
    error(403) unless current_ability.can? :read, @client

    metrics=@client.providers.select{|p| !p.deleted}.map{|provider|
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

      {:category_type=>metric.provider.name,:category_icon=>icons[metric.provider.provider_name.to_sym],:id=>metric.provider.id,:metric_name=>metric.name,:average=>average,:range_start=>rangestart,:range_end=>rangeend,:sparkline=>sparkline,:num_observations=>metric.observations.size}
    }.group_by{|s| [s[:category_type],s[:category_icon],s[:id]]}
    render 'clients/show'
  end
end