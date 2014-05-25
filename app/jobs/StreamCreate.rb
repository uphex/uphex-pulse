class StreamCreate
  @queue = :StreamCreate
  def self.perform(provider_id)
    puts 'StreamCreate invoked'

    metrics=[]

    provider=Provider.find(provider_id)

    case provider['provider_name']
      when 'google'
        metrics << Metric.new(:provider=>provider,:name=>'visits',:updated_at=>DateTime.new,:analyzed_at=>DateTime.new)
        metrics << Metric.new(:provider=>provider,:name=>'visitors',:updated_at=>DateTime.new,:analyzed_at=>DateTime.new)
        metrics << Metric.new(:provider=>provider,:name=>'bounces',:updated_at=>DateTime.new,:analyzed_at=>DateTime.new)
      when 'facebook'
        metrics << Metric.new(:provider=>provider,:name=>'visits',:updated_at=>DateTime.new,:analyzed_at=>DateTime.new)
        metrics << Metric.new(:provider=>provider,:name=>'likes',:updated_at=>DateTime.new,:analyzed_at=>DateTime.new)
      when 'twitter'
        metrics << Metric.new(:provider=>provider,:name=>'followers',:updated_at=>DateTime.new,:analyzed_at=>DateTime.new)
    end

    metrics.each{|metric|
        metric.save!
        Resque.enqueue(MetricUpdate,metric[:id])
    }
  end
end
