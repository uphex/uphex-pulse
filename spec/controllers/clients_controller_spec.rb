require 'environment_spec_helper'

describe 'ClientsController' do

  before do
    ResqueSpec.reset!
  end

  it 'should display a message about fetching data and when there are not enough data points' do
    create_sample_user
    create_sample_portfolio
    create_sample_metric

    Timecop.freeze(Time.utc(2014,2,29)) do

      get '/clients/'+Portfolio.all.first.id.to_s
      expect(last_response.body).to include 'Fetching data'

      Observation.create(:index=>Time.utc(2014,2,26),:value=>2,:metric=>Metric.first).save!

      get '/clients/'+Portfolio.all.first.id.to_s
      expect(last_response.body).to include 'Not enough data yet'

      Observation.create(:index=>Time.utc(2014,2,28),:value=>2,:metric=>Metric.first).save!

      get '/clients/'+Portfolio.all.first.id.to_s
      expect(last_response.body).not_to include 'Fetching data'
    end
  end

  it 'should humanize all metric name before display' do
    create_sample_user
    create_sample_portfolio
    create_sample_metric

    ad_click_metric=Metric.create({
                      :provider => Provider.first,
                      :name => 'adClicks',
                      :updated_at => DateTime.new,
                      :analyzed_at => DateTime.new
                  })

    get '/clients/'+Portfolio.all.first.id.to_s

    expect(last_response.body).not_to include 'adClicks'
    expect(last_response.body).to include 'Ad clicks'

    Observation.create(:index=>Time.utc(2014,2,27),:value=>2,:metric=>ad_click_metric).save!
    Observation.create(:index=>Time.utc(2014,2,28),:value=>2,:metric=>ad_click_metric).save!
    event1=Event.create(:date=>Time.utc(2014,2,27),:prediction_low=>0,:prediction_high=>1,:metric=>ad_click_metric)
    event1.save!

    get '/clients/'+Portfolio.all.first.id.to_s

    expect(last_response.body).not_to include 'adClicks'
    expect(last_response.body).to include 'Ad clicks'

    get '/users/me/dashboard'

    expect(last_response.body).not_to include 'adClicks'
    expect(last_response.body).to include 'Ad clicks'

    get '/events?portfolioid='+Portfolio.all.first.id.to_s

    expect(last_response.body).not_to include 'adClicks'
    expect(last_response.body).to include 'Ad clicks'

  end
end
