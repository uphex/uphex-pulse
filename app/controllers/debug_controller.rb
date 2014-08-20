UpHex::Pulse.controllers :debug do

  get '/' do
    error(403) unless is_admin?

    if params['metric'].nil?
      @metrics = Metric.all.sort_by{|metric| metric.provider.portfolio.organization.name+'/'+metric.provider.portfolio.name+'/'+metric.provider.name+'/'+metric.name}
    else
      metric_helper=DebugHelper.new(params['metric'])
      @metric=metric_helper.metric
      @observations=metric_helper.observations
      @sparkline=metric_helper.sparkline
      @bands=metric_helper.bands
      @events=metric_helper.events
    end


    render 'debug/streams'
  end
end
