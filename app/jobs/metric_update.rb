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

      require 'uphex-estimation'


      sparkline=SparklineNormalizer.new.normalize(metric.observations)

      full_data=sparkline.map{|sparkline|
        {:date=>sparkline[:index].to_date,:value=>sparkline[:value].round}
      }.sort_by{|val| val[:date]}

      ts = UpHex::Prediction::TimeSeries.new(full_data, :days => 1)

      analyzed_num=(full_data.select{|val| val[:date]<metric['analyzed_at']}.size-1)

      if analyzed_num<2
        analyzed_num=[[full_data.size/2,30].max,full_data.size-1].min
      end

      if analyzed_num>=2
        range = 0..analyzed_num
        results = UpHex::Prediction::ExponentialMovingAverageStrategy.new(ts).comparison_forecast(1, :range => range, :confidence => 0.99)
        results.each{|result|
          found=full_data.find{|val| val[:date]==result[:date]}
          unless found.nil?
            if found[:value]<result[:low] or found[:value]>result[:high]
              puts result
              puts found
            end
          end
        }
      end
    rescue => e
      puts e.inspect, e.backtrace
    end

  end
end
