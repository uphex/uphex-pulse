class StreamCreate
  @queue = :StreamCreate
  def self.perform(provider_id)
    puts 'StreamCreate invoked'

    metrics=[]

    provider=Provider.find(provider_id)

    metric_names = case provider['provider_name']
       when 'google'
         ['visits', 'visitors', 'bounces','impressions','adClicks','organicSearches']
       when 'facebook'
         %w(visits likes pageImpressionsPaid pagePostsImpressionsPaid postImpressionsPaid postImpressionsFanPaid postVideoCompleteViewsPaid postVideoViewsPaid)
       when 'twitter'
         ['followers']
       when 'mailchimp'
         %w(hard_bounces soft_bounces unsubscribes forwards unique_opens unique_clicks)
     end

    metric_names.each do |name|
      metrics << Metric.new(:provider=>provider,:name=>name,:updated_at=>DateTime.new,:analyzed_at=>DateTime.new)
    end

    metrics.each{|metric|
        metric.save!
        Resque.enqueue(MetricUpdate,metric[:id])
    }
  end
end
