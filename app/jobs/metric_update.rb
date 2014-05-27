class MetricUpdate
  @queue = :MetricUpdate
  def self.perform(metric_id)
    puts 'MetricUpdate invoked'

    begin

      metric = Metric.find(metric_id)

      config = JSON.parse(File.read(File.expand_path("../../../config/auth_config.json", __FILE__)))

      since= metric['updated_at'] < DateTime.now.to_date - 180 ? DateTime.now.to_date - 180 : metric['updated_at']

      case metric.provider['provider_name']
        when 'google'
          configpart=config['oauth-v2']['providers']['google']
          client=Uphex::Prototype::Cynosure::Shiatsu.client(:google,configpart['identifier'],configpart['secret']).authenticate(metric.provider[:access_token],metric.provider[:expiration_date],metric.provider[:refresh_token])
          client.profile=client.profiles.find{|profile| profile.id==metric.provider['profile_id']}
          case metric['name']
            when 'visits'
              value=client.visits(since,DateTime.now,:day)
            when 'visitors'
              value=client.visitors(since,DateTime.now,:day)
            when 'bounces'
              value=client.bounces(since,DateTime.now,:day)
          end
          value.value.each{|metric_day|
            Observation.create(:metric=>metric,:index=>metric_day[:timestamp],:value=>metric_day[:payload])
          }
          metric['updated_at']=DateTime.now
          metric.save!

        when 'facebook'
          client=Uphex::Prototype::Cynosure::Shiatsu.client(:facebook,nil,nil).authenticate(metric.provider[:access_token])
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
          configpart=config['oauth-v1']['providers']['twitter']
          client=Uphex::Prototype::Cynosure::Shiatsu.client(:twitter,configpart['consumer_key'],configpart['consumer_secret']).authenticate(metric.provider[:access_token],metric.provider[:access_token_secret])
          case metric['name']
            when 'followers'
              Observation.create(:metric=>metric,:index=>DateTime.now,:value=>client.followers_count)
          end
          metric['updated_at']=DateTime.now
          metric.save!
      end
    rescue => e
      puts e.inspect, e.backtrace
    end

  end
end
