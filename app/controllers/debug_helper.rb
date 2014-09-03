class DebugHelper
  def initialize(metric_id)
    @metric_id=metric_id
  end

  def metric
    @metric ||= Metric.find(@metric_id)
  end
  def observations
    @observations ||= metric.observations
  end

  def sparkline
    @sparkline ||= SparklineNormalizer.new.normalize(observations)
  end

  def bands
    @bands ||= begin
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
  end

  def events
    @events ||= metric.events
  end

  def anomalies
    @anomalies ||= begin
      sparkline.map{|point|
        matching_band=bands.find{|band| band[:date]==point[:index]}
        matching_event=events.find{|event| event[:date]==point[:index]}
        crossing=(!matching_band.nil? and (matching_band[:high]<point[:value].round or matching_band[:low]>point[:value].round))
        {:metric=>metric,:date=>point[:index],:crossing=>crossing,:event=>!matching_event.nil?} unless !crossing and matching_event.nil?
      }.compact
    end
  end
end