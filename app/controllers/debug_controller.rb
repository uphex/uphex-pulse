UpHex::Pulse.controllers :debug do

  get '/' do
    error(403) unless is_admin?

    @metrics = Metric.all.sort_by{|metric| full_metric_name(metric)}

    unless params['metric'].nil?
      metric_helper=DebugHelper.new(params['metric'])
      @metric=metric_helper.metric
      @observations=metric_helper.observations
      @sparkline=metric_helper.sparkline
      @bands=metric_helper.bands
      @events=metric_helper.events
    end

    render 'debug/streams'
  end

  get '/events' do
    error(403) unless is_admin?

    @anomalies=Metric.all.flat_map{|metric|
      DebugHelper.new(metric.id).anomalies
    }.compact.group_by{|anomaly| anomaly[:date]}.to_a.sort_by{|a| a}.reverse

    render 'debug/events'
  end
end
