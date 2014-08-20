require 'environment_spec_helper'

describe 'ClientsController' do

  before do
    ResqueSpec.reset!
  end

  after do
    Timecop.return
  end

  it 'should display a message about fetching data and when there are not enough data points' do
    create_sample_user
    create_sample_portfolio
    create_sample_metric

    Timecop.freeze(Time.utc(2014,02,29))

    get '/clients/'+Portfolio.all.first.id.to_s
    expect(last_response.body).to include 'Fetching data'

    Observation.create(:index=>Time.utc(2014,02,26),:value=>2,:metric=>Metric.first).save!

    get '/clients/'+Portfolio.all.first.id.to_s
    expect(last_response.body).to include 'Not enough data yet'

    Observation.create(:index=>Time.utc(2014,02,28),:value=>2,:metric=>Metric.first).save!

    get '/clients/'+Portfolio.all.first.id.to_s
    expect(last_response.body).not_to include 'Fetching data'
  end
end
