class MetricUpdate
  @queue = :MetricUpdate
  def self.perform(metric_id)
    puts 'MetricUpdate invoked'

    begin
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
              Observation.destroy_all({:metric=>metric,:index => metric_day[:timestamp]})
              Observation.create(:metric=>metric,:index=>metric_day[:timestamp],:value=>metric_day[:payload])
            }

          when 'facebook'
            client=Uphex::Prototype::Cynosure::Shiatsu.client(:facebook,nil,nil).authenticate(metric.provider[:access_token])
            case metric['name']
              when 'visits'
                value=client.page_visits(since)
              when 'likes'
                value=client.page_likes(since)
            end
            value.value.each{|metric_day|
              Observation.destroy_all({:metric=>metric,:index => metric_day[:timestamp]})
              Observation.create(:metric=>metric,:index=>metric_day[:timestamp],:value=>metric_day[:payload])
            }

          when 'twitter'
            configpart=config['oauth-v1']['providers']['twitter']
            client=Uphex::Prototype::Cynosure::Shiatsu.client(:twitter,configpart['consumer_key'],configpart['consumer_secret']).authenticate(metric.provider[:access_token],metric.provider[:access_token_secret])
            case metric['name']
              when 'followers'
                Observation.create(:metric=>metric,:index=>DateTime.now,:value=>client.followers_count)
            end
        end

        metric['updated_at']=DateTime.now
        metric['last_error_type']=nil
        metric['last_error_time']=nil
        metric.save!

        require 'uphex-estimation'


        sparkline=SparklineNormalizer.new.normalize(metric.observations)

        full_data=sparkline.map{|sline|
          {:date=>sline[:index].to_date,:value=>sline[:value].round}
        }.sort_by{|val| val[:date]}

        unless full_data.length==0
          ts = UpHex::Prediction::TimeSeries.new(full_data, :days => 1)

          analyzed_num=(full_data.select{|val| val[:date]<metric['analyzed_at']}.size-1)

          if analyzed_num<2
            analyzed_num=[[full_data.size/2,30].max,full_data.size-1].min
          end

          if analyzed_num>=2
            range = 0..analyzed_num
            results = UpHex::Prediction::ExponentialMovingAverageStrategy.new(ts).comparison_forecast(1, :range => range, :confidence => 0.99)
            results.each{|result|
              low=[result[:low].floor,0].max
              high=result[:high].ceil
              found=full_data.find{|val| val[:date]==result[:date]}
              unless found.nil?
                if found[:value]<low or found[:value]>high
                  event=Event.create(:metric=>metric,:date=>found[:date],:prediction_low=>low,:prediction_high=>high)
                  puts event
                end
              end
            }
            metric['analyzed_at']=DateTime.now
            metric.save!
          end
        end
      rescue OAuth2::Error => e
        if e.code['code']==401 or e.code=='invalid_grant'
          metric['last_error_time']=DateTime.now
          metric['last_error_type']=:disconnected
          metric.save!
        else
          raise e
        end
      rescue Koala::Facebook::AuthenticationError
        metric['last_error_time']=DateTime.now
        metric['last_error_type']=:disconnected
        metric.save!
      rescue Twitter::Error::Unauthorized
        metric['last_error_time']=DateTime.now
        metric['last_error_type']=:disconnected
        metric.save!
      end
    rescue => e
      metric['last_error_time']=DateTime.now
      metric['last_error_type']=:other
      metric.save!
      puts e.inspect, e.backtrace
    end

  end
end
