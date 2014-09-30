require File.expand_path(File.dirname(__FILE__) + "/../../app/controllers/sparkline_normalizer_proposed")
require 'spec/environment_spec_helper'

describe 'SparklineNormalizerProposed' do
  describe 'single day' do
    it 'should work for some data points in a day', :broken => true do
      expect(SparklineNormalizerProposed.new.normalize([
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
                                               ])).to match_array(
                                                          [{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>175}]
                                                      )
    end

    it 'should return the observation if there is only one for a day' do
      expect(SparklineNormalizerProposed.new.normalize([
                                                           {
                                                               :index=>DateTime.new(2014,5,4,0,0),
                                                               :value=>100
                                                           },
                                                           {
                                                               :index=>DateTime.new(2014,5,5,0,0),
                                                               :value=>60
                                                           }
                                                       ])).to match_array(
                                                                  [{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>100}]
                                                              )
    end

    it 'should step when there is a gap' do
      expect(SparklineNormalizerProposed.new.normalize([
                                                           {
                                                               :index=>DateTime.new(2014,5,4,0,0),
                                                               :value=>100
                                                           },
                                                           {
                                                               :index=>DateTime.new(2014,5,7,0,0),
                                                               :value=>200
                                                           }
                                                       ])).to match_array(
                                                                  [{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>100},
                                                                   {:index=>DateTime.new(2014,5,5,0,0).to_date,:value=>150},
                                                                  {:index=>DateTime.new(2014,5,6,0,0).to_date,:value=>200}]
                                                              )
    end

    it 'should step down when there is a gap downwards' do
      expect(SparklineNormalizerProposed.new.normalize([
                                                           {
                                                               :index=>DateTime.new(2014,5,4,0,0),
                                                               :value=>200
                                                           },
                                                           {
                                                               :index=>DateTime.new(2014,5,7,0,0),
                                                               :value=>100
                                                           }
                                                       ])).to match_array(
                                                                  [{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>200},
                                                                   {:index=>DateTime.new(2014,5,5,0,0).to_date,:value=>150},
                                                                   {:index=>DateTime.new(2014,5,6,0,0).to_date,:value=>100}]
                                                              )
    end

    it 'should return an empty array if called with an empty array' do
      expect(SparklineNormalizerProposed.new.normalize([])).to match_array([])
    end
  end
end
