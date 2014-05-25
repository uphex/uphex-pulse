class OldestMetricUpdate
  @queue = :OldestMetricUpdate
  def self.perform
    puts 'OldestMetricUpdate provider'
    oldestmetric=Metric.order('updated_at ASC').first
    unless oldestmetric.nil?
      Resque.enqueue(MetricUpdate,oldestmetric[:id])
    end
  end
end
