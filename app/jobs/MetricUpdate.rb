class MetricUpdate
  @queue = :MetricUpdate
  def self.perform(metric_id)
    puts 'MetricUpdate invoked'

    metric = Metric.find(metric_id)
    puts metric.attributes
  end
end
