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
    @anomalies ||= make_anomalies
  end

  def make_anomalies
    anomalies_list=[]
    sparkline.each{|point|
      point_value=point[:value].round
      matching_band=bands.find{|band| band[:date]==point[:index]}
      crossing=(!matching_band.nil? and (matching_band[:high]<point_value or matching_band[:low]>point_value))
      matching_event=events.find{|event| event[:date]==point[:index]}
      event=!matching_event.nil?
      if crossing or event
        anomalies_list << {:metric=>metric,:date=>point[:index],:crossing=>crossing,:event=>event}
      end
    }
    anomalies_list
  end
end