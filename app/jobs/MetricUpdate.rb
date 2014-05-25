class MetricUpdate
  @queue = :MetricUpdate
  def self.perform
    puts 'MetricUpdate invoked'
  end
end
