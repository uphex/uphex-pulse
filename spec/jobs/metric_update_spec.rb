require 'environment_spec_helper'
require 'ostruct'

describe 'MetricUpdate' do

  before do
    ResqueSpec.reset!
  end

  it 'should be able to fetch observations' do
    create_sample_user
    create_sample_portfolio
    create_sample_metric

    Timecop.freeze(Time.utc(2014,2,29)) do

      profile1=OpenStruct.new({:name=>'test_profile_id1',:id=>'test_profile_id1',:visits=>
          [OpenStruct.new(:date=>'20140220',:visits=>'1'),
           OpenStruct.new(:date=>'20140221',:visits=>'2'),
           OpenStruct.new(:date=>'20140222',:visits=>'2'),
           OpenStruct.new(:date=>'20140223',:visits=>'1'),
           OpenStruct.new(:date=>'20140224',:visits=>'1'),
           OpenStruct.new(:date=>'20140225',:visits=>'1'),
           OpenStruct.new(:date=>'20140226',:visits=>'1'),
           OpenStruct.new(:date=>'20140227',:visits=>'2'),
           OpenStruct.new(:date=>'20140228',:visits=>'2')
          ]
      })
      Legato::User.any_instance.stub(:accounts=>[OpenStruct.new({:id=>'account_id',:name=>'account',:profiles=>[profile1]})])

      allow(Uphex::Prototype::Cynosure::Shiatsu::Google::Client::Visits).to receive(:results).and_return(profile1.visits)

      MetricUpdate.perform(Metric.all.first.id)

      expect(Metric.all.first['last_error_type']).to be_nil

      expect(Observation.all.size).to eq profile1[:visits].size
    end

  end

  it 'should not save today\'s observation' do
    create_sample_user
    create_sample_portfolio
    create_sample_metric

    profile1=OpenStruct.new({:name=>'test_profile_id1',:id=>'test_profile_id1',:visits=>
        [OpenStruct.new(:date=>'20140220',:visits=>'1'),
         OpenStruct.new(:date=>'20140221',:visits=>'2'),
         OpenStruct.new(:date=>'20140222',:visits=>'2'),
         OpenStruct.new(:date=>'20140223',:visits=>'1'),
         OpenStruct.new(:date=>'20140224',:visits=>'1'),
         OpenStruct.new(:date=>'20140225',:visits=>'1'),
         OpenStruct.new(:date=>'20140226',:visits=>'1'),
         OpenStruct.new(:date=>'20140227',:visits=>'2'),
         OpenStruct.new(:date=>'20140228',:visits=>'2')
        ]
                            })
    Timecop.freeze(Time.utc(2014,2,27)) do

      Legato::User.any_instance.stub(:accounts=>[OpenStruct.new({:id=>'account_id',:name=>'account',:profiles=>[profile1]})])

      allow(Uphex::Prototype::Cynosure::Shiatsu::Google::Client::Visits).to receive(:results).and_return(profile1.visits)

      MetricUpdate.perform(Metric.all.first.id)

    end

    expect(Metric.all.first['last_error_type']).to be_nil

    expect(Observation.all.size).to eq profile1[:visits].size-2

    Timecop.freeze(Time.utc(2014,2,28,2)) do
      MetricUpdate.perform(Metric.all.first.id)
    end
    expect(Metric.all.first['last_error_type']).to be_nil
    expect(Observation.all.size).to eq profile1[:visits].size-1

    Timecop.freeze(Time.utc(2014,2,29)) do
      MetricUpdate.perform(Metric.all.first.id)
    end
    expect(Metric.all.first['last_error_type']).to be_nil
    expect(Observation.all.size).to eq profile1[:visits].size
  end

  it 'should report disconnected error when an auth error occurs' do
    create_sample_user
    create_sample_portfolio
    create_sample_metric

    OAuth2::Error.any_instance.stub(:initialize=>{},:code=>'invalid_grant')

    Legato::User.any_instance.stub(:accounts) do
      raise OAuth2::Error.new({})
    end

    MetricUpdate.perform(Metric.all.first.id)

    expect(Metric.all.first['last_error_type']).to eq 'disconnected'
  end


  it 'should refresh the token if there is an auth error when updating the metric' do
    create_sample_user
    create_sample_portfolio
    create_sample_metric

    Timecop.freeze(Time.utc(2014,2,21)) do

      profile1=OpenStruct.new({:name=>'test_profile_id1',:id=>'test_profile_id1',:visits=>
          [OpenStruct.new(:date=>'20140220',:visits=>'1')
          ]
                              })

      allow(Uphex::Prototype::Cynosure::Shiatsu::Google::Client::Visits).to receive(:results).and_return(profile1.visits)

      OAuth2::Error.any_instance.stub(:initialize=>{},:code=>'invalid_grant')

      Legato::User.any_instance.stub(:accounts) do
        Legato::User.any_instance.unstub(:accounts)
        Legato::User.any_instance.stub(:accounts) do
          [OpenStruct.new({:id=>'account_id',:name=>'account',:profiles=>[profile1]})]
        end
        raise OAuth2::Error.new({})
      end

      OAuth2::AccessToken.any_instance.should_receive(:refresh!) do
        OpenStruct.new(:token=>'refreshed_access_token',:expires_in=>'10000')
      end

      MetricUpdate.perform(Metric.all.first.id)
    end

    expect(Observation.all.size).to be >= 1
  end

  it 'should refresh the token if the expiration date is due' do
    create_sample_user
    create_sample_portfolio
    create_sample_metric

    Provider.all.each{|provider|
      provider[:expiration_date]=Time.utc(2014,2,21)-1.days
      provider.save!
    }

    Timecop.freeze(Time.utc(2014,2,21)) do

      profile1=OpenStruct.new({:name=>'test_profile_id1',:id=>'test_profile_id1',:visits=>
          [OpenStruct.new(:date=>'20140220',:visits=>'1')
          ]
                              })

      allow(Uphex::Prototype::Cynosure::Shiatsu::Google::Client::Visits).to receive(:results).and_return(profile1.visits)

      OAuth2::Error.any_instance.stub(:initialize=>{},:code=>'invalid_grant')

      Legato::User.any_instance.stub(:accounts) do
        if @refreshed==true
          [OpenStruct.new({:id=>'account_id',:name=>'account',:profiles=>[profile1]})]
        else
          @called_without_refresh=true
          raise OAuth2::Error.new({})
        end

      end

      OAuth2::AccessToken.any_instance.should_receive(:refresh!) do
        @refreshed=true
        OpenStruct.new(:token=>'refreshed_access_token',:expires_in=>'10000')
      end

      MetricUpdate.perform(Metric.all.first.id)
    end

    expect(Observation.all.size).to be >= 1
    expect(@called_without_refresh).to eq nil
  end

  it 'should generate an event for an extraneous data point' do
    create_sample_user
    create_sample_portfolio
    create_sample_metric

    profile1=OpenStruct.new({:name=>'test_profile_id1',:id=>'test_profile_id1',:visits=>
        [OpenStruct.new(:date=>'20140120',:visits=>'1'),
         OpenStruct.new(:date=>'20140121',:visits=>'1'),
         OpenStruct.new(:date=>'20140122',:visits=>'1'),
         OpenStruct.new(:date=>'20140123',:visits=>'1'),
         OpenStruct.new(:date=>'20140124',:visits=>'1'),
         OpenStruct.new(:date=>'20140125',:visits=>'1'),
         OpenStruct.new(:date=>'20140126',:visits=>'1'),
         OpenStruct.new(:date=>'20140127',:visits=>'1'),
         OpenStruct.new(:date=>'20140128',:visits=>'1'),
         OpenStruct.new(:date=>'20140129',:visits=>'1'),
         OpenStruct.new(:date=>'20140130',:visits=>'1'),
         OpenStruct.new(:date=>'20140131',:visits=>'1'),
         OpenStruct.new(:date=>'20140201',:visits=>'1'),
         OpenStruct.new(:date=>'20140202',:visits=>'1'),
         OpenStruct.new(:date=>'20140203',:visits=>'1'),
         OpenStruct.new(:date=>'20140204',:visits=>'1'),
         OpenStruct.new(:date=>'20140205',:visits=>'1'),
         OpenStruct.new(:date=>'20140206',:visits=>'1'),
         OpenStruct.new(:date=>'20140207',:visits=>'1'),
         OpenStruct.new(:date=>'20140208',:visits=>'1'),
         OpenStruct.new(:date=>'20140209',:visits=>'1'),
         OpenStruct.new(:date=>'20140210',:visits=>'1'),
         OpenStruct.new(:date=>'20140211',:visits=>'1'),
         OpenStruct.new(:date=>'20140212',:visits=>'1'),
         OpenStruct.new(:date=>'20140213',:visits=>'1'),
         OpenStruct.new(:date=>'20140214',:visits=>'1'),
         OpenStruct.new(:date=>'20140215',:visits=>'1'),
         OpenStruct.new(:date=>'20140216',:visits=>'1'),
         OpenStruct.new(:date=>'20140217',:visits=>'1'),
         OpenStruct.new(:date=>'20140218',:visits=>'1'),
         OpenStruct.new(:date=>'20140219',:visits=>'1'),
         OpenStruct.new(:date=>'20140221',:visits=>'2'),
         OpenStruct.new(:date=>'20140222',:visits=>'2'),
         OpenStruct.new(:date=>'20140223',:visits=>'1'),
         OpenStruct.new(:date=>'20140224',:visits=>'1'),
         OpenStruct.new(:date=>'20140225',:visits=>'1'),
         OpenStruct.new(:date=>'20140226',:visits=>'1'),
         OpenStruct.new(:date=>'20140227',:visits=>'200')
        ]
                            })

    Timecop.freeze(Time.utc(2014,2,29)) do

      Legato::User.any_instance.stub(:accounts=>[OpenStruct.new({:id=>'account_id',:name=>'account',:profiles=>[profile1]})])

      allow(Uphex::Prototype::Cynosure::Shiatsu::Google::Client::Visits).to receive(:results).and_return(profile1.visits)

      MetricUpdate.perform(Metric.all.first.id)
    end

    expect(Event.all.size).to eq 1
  end

  it 'should set and update the metric timestamps' do
    create_sample_user
    create_sample_portfolio

    Rack::OAuth2::Client.any_instance.should_receive(:authorization_code=) do |arg|
      expect(arg).to eq 'sample_code'
    end

    Rack::OAuth2::Client.any_instance.stub(:access_token!) do |arg|
      OpenStruct.new({:access_token=>'access_token',:expires_in=>DateTime.now+1.days,:refresh_token=>'refresh_token'})
    end

    profile1=OpenStruct.new({:name=>'test_profile_id1',:id=>'test_profile_id1',:visits=>
        [OpenStruct.new(:date=>'20140120',:visits=>'1'),
         OpenStruct.new(:date=>'20140121',:visits=>'1'),
         OpenStruct.new(:date=>'20140122',:visits=>'1'),
         OpenStruct.new(:date=>'20140123',:visits=>'1'),
         OpenStruct.new(:date=>'20140124',:visits=>'1'),
         OpenStruct.new(:date=>'20140125',:visits=>'1')
        ]
                            })

    allow(Uphex::Prototype::Cynosure::Shiatsu::Google::Client::Visits).to receive(:results).and_return(profile1.visits)

    Legato::User.any_instance.stub(:accounts=>[OpenStruct.new({:id=>'account_id',:name=>'account',:profiles=>[OpenStruct.new({:name=>'test_profile',:id=>'test_profile_id'})]})])

    get '/auth/oauth-v2/google/callback?state='+CGI::escape({:portfolioid=>Portfolio.all.first.id}.to_json)+'&code=sample_code'

    Timecop.freeze(Time.utc(2014,3,1)) do
      ResqueSpec.perform_all(:StreamCreate)
    end

    Metric.all.each{|metric|
      expect(metric.created_at).to eq Time.utc(2014,3,1)
      expect(metric.updated_at).to be < Time.utc(2014,3,1)
      expect(metric.analyzed_at).to be < Time.utc(2014,3,1)
    }

    Timecop.freeze(Time.utc(2014,3,2)) do

      metric_to_update=Metric.all.first

      MetricUpdate.perform(metric_to_update.id)

      metric_to_update=Metric.find(metric_to_update.id)

      expect(metric_to_update.created_at).to eq Time.utc(2014,3,1)
      expect(metric_to_update.updated_at).to eq Time.utc(2014,3,2)
      expect(metric_to_update.analyzed_at).to eq Time.utc(2014,3,2)
    end

  end

  it 'should generate an event for an extraneous data point when fetching continuously' do
    create_sample_user
    create_sample_portfolio
    create_sample_metric

    profile1=OpenStruct.new({:name=>'test_profile_id1',:id=>'test_profile_id1',:visits=>
        [OpenStruct.new(:date=>'20140120',:visits=>'1'),
         OpenStruct.new(:date=>'20140121',:visits=>'1'),
         OpenStruct.new(:date=>'20140122',:visits=>'1'),
         OpenStruct.new(:date=>'20140123',:visits=>'1'),
         OpenStruct.new(:date=>'20140124',:visits=>'1'),
         OpenStruct.new(:date=>'20140125',:visits=>'1'),
         OpenStruct.new(:date=>'20140126',:visits=>'1'),
         OpenStruct.new(:date=>'20140127',:visits=>'2'),
         OpenStruct.new(:date=>'20140128',:visits=>'1'),
         OpenStruct.new(:date=>'20140129',:visits=>'1'),
         OpenStruct.new(:date=>'20140130',:visits=>'1'),
         OpenStruct.new(:date=>'20140131',:visits=>'1'),
         OpenStruct.new(:date=>'20140201',:visits=>'1'),
         OpenStruct.new(:date=>'20140202',:visits=>'1'),
         OpenStruct.new(:date=>'20140203',:visits=>'1'),
         OpenStruct.new(:date=>'20140204',:visits=>'1'),
         OpenStruct.new(:date=>'20140205',:visits=>'1'),
         OpenStruct.new(:date=>'20140206',:visits=>'1'),
         OpenStruct.new(:date=>'20140207',:visits=>'2'),
         OpenStruct.new(:date=>'20140208',:visits=>'1'),
         OpenStruct.new(:date=>'20140209',:visits=>'1'),
         OpenStruct.new(:date=>'20140210',:visits=>'1'),
         OpenStruct.new(:date=>'20140211',:visits=>'200'),
         OpenStruct.new(:date=>'20140212',:visits=>'1'),
         OpenStruct.new(:date=>'20140213',:visits=>'1'),
         OpenStruct.new(:date=>'20140214',:visits=>'1'),
         OpenStruct.new(:date=>'20140215',:visits=>'1')
        ]
                            })
    Legato::User.any_instance.stub(:accounts=>[OpenStruct.new({:id=>'account_id',:name=>'account',:profiles=>[profile1]})])


    hour = Time.utc(2014,2,10)
    begin
      Timecop.freeze(hour) do
        allow(Uphex::Prototype::Cynosure::Shiatsu::Google::Client::Visits).to receive(:results).and_return(profile1.visits.select{|v| Date.parse(v.date).to_time<hour})

        MetricUpdate.perform(Metric.all.first.id)
      end
    end while (hour += 36000) < Time.utc(2014,2,15)

    expect(Event.all.size).to eq 2
  end


  it 'should fetch intermittent data points when a period of error occures then the connection is restored' do
    create_sample_user
    create_sample_portfolio

    profile1=OpenStruct.new({:name=>'test_profile_id1',:id=>'test_profile_id1',:visits=>
        [OpenStruct.new(:date=>'20140120',:visits=>'1'),
         OpenStruct.new(:date=>'20140121',:visits=>'1'),
         OpenStruct.new(:date=>'20140122',:visits=>'1'),
         OpenStruct.new(:date=>'20140123',:visits=>'1'),
         OpenStruct.new(:date=>'20140124',:visits=>'1'),
         OpenStruct.new(:date=>'20140125',:visits=>'1'),
         OpenStruct.new(:date=>'20140126',:visits=>'1'),
         OpenStruct.new(:date=>'20140127',:visits=>'1'),
         OpenStruct.new(:date=>'20140128',:visits=>'1'),
         OpenStruct.new(:date=>'20140129',:visits=>'1')
        ]
                            })

    Timecop.freeze(Time.utc(2014,1,21)) do
      create_sample_metric

      Legato::User.any_instance.stub(:accounts=>[OpenStruct.new({:id=>'account_id',:name=>'account',:profiles=>[profile1]})])

      OAuth2::Error.any_instance.stub(:initialize=>{},:code=>'invalid_grant')

      allow(Uphex::Prototype::Cynosure::Shiatsu::Google::Client::Visits).to receive(:results){profile1.visits.select{|v| Date.parse(v.date).to_time<=Time.now}}

      MetricUpdate.perform(Metric.all.first.id)
    end

    allow(Uphex::Prototype::Cynosure::Shiatsu::Google::Client::Visits).to receive(:results){raise OAuth2::Error.new({})}

    (22...29).each{|day|
      Timecop.freeze(Time.utc(2014,1,day)) do
        MetricUpdate.perform(Metric.all.first.id)
      end
    }

    allow(Uphex::Prototype::Cynosure::Shiatsu::Google::Client::Visits).to receive(:results){profile1.visits.select{|v| Date.parse(v.date).to_time<=Time.now}}

    Timecop.freeze(Time.utc(2014,1,29)) do
      MetricUpdate.perform(Metric.all.first.id)
    end

    expect(Observation.all.size).to eq 9

  end

end
