require 'environment_spec_helper'
require 'app/helpers/events_helper'

describe 'EventsHelper' do
  include EventsHelper

  it 'should correctly format stream name' do
    expect(format_stream_name('adClicks')).to eq 'Ad clicks'
  end
end
