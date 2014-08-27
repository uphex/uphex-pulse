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

    puts eventName

    render 'debug/streams'
  end
end
