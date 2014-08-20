class DebugHelper
  def initialize(metric_id)
    @metric_id=metric_id
  end

  def metric
    Metric.find(@metric_id)
  end

  def observations
    metric.observations
  end

  def sparkline
    SparklineNormalizer.new.normalize(observations)
  end

  def bands
    full_data=sparkline.map{|sline|
      {:date=>sline[:index].to_date,:value=>sline[:value].round}
    }.sort_by{|val| val[:date]}

    ts = UpHex::Prediction::TimeSeries.new(full_data, :days => 1)
    range = 0..1
    results = UpHex::Prediction::ExponentialMovingAverageStrategy.new(ts).comparison_forecast(1, :range => range, :confidence => 0.99)

    results.map{|result|
      {:low=>[result[:low].floor,0].max,:high=>result[:high].ceil,:date=>result[:date]}
    }
  end

  def events
    metric.events
  end
end