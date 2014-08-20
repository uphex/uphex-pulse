UpHex::Pulse.controllers :debug do

  get '/' do
    error(403) unless is_admin?
    @metrics = Metric.all.sort_by{|metric| metric.provider.portfolio.organization.name+'/'+metric.provider.portfolio.name+'/'+metric.provider.name+'/'+metric.name}
    params['metric'] ||= @metrics.first.id.to_s

    metric=Metric.find(params['metric'])
    @observations=metric.observations
    @sparkline=SparklineNormalizer.new.normalize(metric.observations)

    full_data=@sparkline.map{|sline|
      {:date=>sline[:index].to_date,:value=>sline[:value].round}
    }.sort_by{|val| val[:date]}

    ts = UpHex::Prediction::TimeSeries.new(full_data, :days => 1)
    range = 0..1
    results = UpHex::Prediction::ExponentialMovingAverageStrategy.new(ts).comparison_forecast(1, :range => range, :confidence => 0.99)

    @bands=results.map{|result|
      {:low=>[result[:low].floor,0].max,:high=>result[:high].ceil,:date=>result[:date]}
    }

    @events=metric.events

    render 'debug/streams'
  end
end
