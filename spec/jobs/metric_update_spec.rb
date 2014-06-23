require 'environment_spec_helper'
require 'ostruct'

describe 'MetricUpdate' do

  after do
    Timecop.return
  end

  it 'should be able to fetch observations' do
    create_sample_user
    create_sample_portfolio
    create_sample_metric

    Timecop.freeze(Time.utc(2014,02,29))

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

    expect(Observation.all.size).to eql profile1[:visits].size
  end

  it 'should not save today\'s observation' do
    create_sample_user
    create_sample_portfolio
    create_sample_metric

    Timecop.freeze(Time.utc(2014,02,27))

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

    expect(Observation.all.size).to eql profile1[:visits].size-2

    Timecop.freeze(Time.utc(2014,02,28,2))
    MetricUpdate.perform(Metric.all.first.id)
    expect(Metric.all.first['last_error_type']).to be_nil
    expect(Observation.all.size).to eql profile1[:visits].size-1

    Timecop.freeze(Time.utc(2014,02,29))
    MetricUpdate.perform(Metric.all.first.id)
    expect(Metric.all.first['last_error_type']).to be_nil
    expect(Observation.all.size).to eql profile1[:visits].size
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

    expect(Metric.all.first['last_error_type']).to eql 'disconnected'
  end

  it 'should generate an event for an extraneous data point' do
    create_sample_user
    create_sample_portfolio
    create_sample_metric

    Timecop.freeze(Time.utc(2014,02,29))

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
    Legato::User.any_instance.stub(:accounts=>[OpenStruct.new({:id=>'account_id',:name=>'account',:profiles=>[profile1]})])

    allow(Uphex::Prototype::Cynosure::Shiatsu::Google::Client::Visits).to receive(:results).and_return(profile1.visits)

    MetricUpdate.perform(Metric.all.first.id)

    expect(Event.all.size).to eql 1
  end
end
