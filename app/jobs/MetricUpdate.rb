class MetricUpdate
  @queue = :MetricUpdate
  def self.perform(metric_id)
    puts 'MetricUpdate invoked'

    metric = Metric.find(metric_id)

    case metric.provider['provider_name']
      when 'google'
      when 'facebook'
        client=Uphex::Prototype::Cynosure::Shiatsu.client(:facebook,nil,nil).authenticate(metric.provider[:access_token])
        since= metric['updated_at'] < DateTime.parse("2014-04-01") ? DateTime.parse("2014-04-01") : metric['updated_at']
        case metric['name']
          when 'visits'
            value=client.page_visits(since)
          when 'likes'
            value=client.page_likes(since)
        end
        value.value.each{|metric_day|
          Observation.create(:metric=>metric,:index=>metric_day[:timestamp],:value=>metric_day[:payload])
        }
        metric['updated_at']=DateTime.now
        metric.save!

      when 'twitter'
    end
  end
end
