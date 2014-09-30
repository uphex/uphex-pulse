UpHex::Pulse.controllers :debug do

  get '/' do
    error(403) unless is_admin?

    @metrics = Metric.all.sort_by{|metric| full_metric_name(metric)}

    unless params['metric'].nil?
      metric_helper=DebugHelper.new(params['metric'],params['use_proposed']=='true')
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

    @metrics = Metric.all

    @metric_names = @metrics.map{|metric|
      {:id=>metric.id,:full_name=>full_metric_name(metric)}
    }

    render 'debug/events'
  end

  get '/events/:id' do
    error(403) unless is_admin?

    require 'json'

    content_type :json
    DebugHelper.new(params[:id],false).anomalies.to_json
  end
end
