require 'environment_spec_helper'

describe 'EventsController' do
  it 'should differentiate between negative and positive metrics' do
    create_sample_user
    create_sample_portfolio
    create_sample_metric

    Observation.create(:index=>Time.utc(2014,2,27),:value=>2,:metric=>Metric.first).save!
    Observation.create(:index=>Time.utc(2014,2,28),:value=>2,:metric=>Metric.first).save!
    event1=Event.create(:date=>Time.utc(2014,2,27),:prediction_low=>0,:prediction_high=>1,:metric=>Metric.first)
    event1.save!

    get '/users/me/dashboard'
    expect(last_response.body).not_to include "icon-thumbs-up2"
    get '/clients/'+Portfolio.first.id.to_s
    expect(last_response.body).not_to include "icon-thumbs-up2"
    get '/events'
    expect(last_response.body).not_to include "icon-thumbs-up2"
    get '/events/'+event1.id.to_s
    expect(last_response.body).to include "Positive anomaly"

    metric=Metric.all.first
    metric.name='bounces'
    metric.save!

    get '/users/me/dashboard'
    expect(last_response.body).to include "icon-thumbs-up2"
    get '/clients/'+Portfolio.first.id.to_s
    expect(last_response.body).to include "icon-thumbs-up2"
    get '/events'
    expect(last_response.body).to include "icon-thumbs-up2"
    get '/events/'+event1.id.to_s
    expect(last_response.body).to include "Negative anomaly"
  end
end