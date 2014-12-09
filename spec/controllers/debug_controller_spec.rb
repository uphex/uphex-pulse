require 'spec/environment_spec_helper'

describe 'DebugController' do
  it 'should not be accessible with a non-admin user' do
    get '/debug'
    expect(last_response.status).to eq 403

    get '/debug/events'
    expect(last_response.status).to eq 403

    create_sample_user
    get '/debug'
    expect(last_response.status).to eq 403

    get '/debug/events'
    expect(last_response.status).to eq 403

    UserRole.create(:user=>User.all.first,:role=>Role.find_by_name('admin'))
    get '/debug'
    expect(last_response.status).to eq 200

    get '/debug/events'
    expect(last_response.status).to eq 200
  end
end