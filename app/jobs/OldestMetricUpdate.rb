class OldestMetricUpdate
  @queue = :OldestMetricUpdate
  def self.perform
    puts 'OldestMetricUpdate provider'
    Resque.enqueue(MetricUpdate)
  end
end
