class StreamCreate
  @queue = :StreamCreate
  def self.perform(portfolio)
    puts 'StreamCreate provider'
    puts portfolio
    Resque.enqueue(MetricUpdate)
  end
end
