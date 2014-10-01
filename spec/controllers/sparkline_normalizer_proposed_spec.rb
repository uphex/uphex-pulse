require File.expand_path(File.dirname(__FILE__) + "/../../app/controllers/sparkline_normalizer_proposed")
require 'spec/environment_spec_helper'

describe 'SparklineNormalizerProposed' do

  before do
    @normalizer=SparklineNormalizerProposed.new
  end
  it 'should work for some data points in a day', :broken => true do
    observations=[
        {
            :index=>DateTime.new(2014,5,4,0,0),
            :value=>100
        },
        {
            :index=>DateTime.new(2014,5,4,12,0),
            :value=>200
        },
        {
            :index=>DateTime.new(2014,5,5,0,0),
            :value=>60
        }
    ]
    expected=[{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>175}]
    expect(@normalizer.normalize(observations)).to match_array(expected)
  end

  it 'should return the observation if there is only one for a day' do
    observations=[
        {
            :index=>DateTime.new(2014,5,4,0,0),
            :value=>100
        },
        {
            :index=>DateTime.new(2014,5,5,0,0),
            :value=>60
        }
    ]
    expected=[{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>100}]
    expect(@normalizer.normalize(observations)).to match_array(expected)
  end

  it 'should step when there is a gap' do
    observations=[
        {
            :index=>DateTime.new(2014,5,4,0,0),
            :value=>100
        },
        {
            :index=>DateTime.new(2014,5,7,0,0),
            :value=>200
        }
    ]
    expected=[{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>100},
              {:index=>DateTime.new(2014,5,5,0,0).to_date,:value=>150},
              {:index=>DateTime.new(2014,5,6,0,0).to_date,:value=>200}]
    expect(@normalizer.normalize(observations)).to match_array(expected)
  end

  it 'should step down when there is a gap downwards' do
    observations=[
        {
            :index=>DateTime.new(2014,5,4,0,0),
            :value=>200
        },
        {
            :index=>DateTime.new(2014,5,7,0,0),
            :value=>100
        }
    ]
    expected=[{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>200},
              {:index=>DateTime.new(2014,5,5,0,0).to_date,:value=>150},
              {:index=>DateTime.new(2014,5,6,0,0).to_date,:value=>100}]
    expect(@normalizer.normalize(observations)).to match_array(expected)
  end

  it 'should return an empty array if called with an empty array' do
    expect(@normalizer.normalize([])).to match_array([])
  end
end
