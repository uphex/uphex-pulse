class OldestMetricUpdate
  @queue = :OldestMetricUpdate
  def self.perform
    begin
      puts 'OldestMetricUpdate provider'
      Metric.all.group_by{|metric| metric.provider[:provider_name]}.each_pair{|provider_name,metrics|
        Resque.enqueue(MetricUpdate,metrics.sort_by{|metric|
          return Time.at(0) if metric[:updated_at].nil? and metric[:last_error_time].nil?
          (metric[:last_error_time].nil? or (!metric[:updated_at].nil? and metric[:updated_at]>metric[:last_error_time]))?metric[:updated_at]:metric[:last_error_time]
        }.first[:id])
      }
    rescue => e
      puts e.inspect, e.backtrace
    end
  end
end
