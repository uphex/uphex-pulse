require File.expand_path(File.dirname(__FILE__) + "/../../app/controllers/sparkline_normalizer")
require 'spec/environment_spec_helper'

describe 'SparklineNormalizer' do
  describe 'single day' do
    it 'should work for some data points in a day', :broken => true do
      expect(SparklineNormalizer.new.normalize([
                                                 {
                                                     :index=>DateTime.new(2014,5,4,0,0),
                                                     :value=>50
                                                 },
                                                 {
                                                     :index=>DateTime.new(2014,5,4,3,0),
                                                     :value=>60
                                                 },
                                                 {
                                                     :index=>DateTime.new(2014,5,4,12,0),
                                                     :value=>200
                                                 },
                                                 {
                                                     :index=>DateTime.new(2014,5,4,18,0),
                                                     :value=>100
                                                 },
                                                 {
                                                     :index=>DateTime.new(2014,5,5,0,0),
                                                     :value=>60
                                                 }
                                             ])).to match_array(
      [{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>113.125}]
      )
    end

    it 'should not return a result for a day that does not have a point after it\'s end' do
      expect(SparklineNormalizer.new.normalize([
                                                   {
                                                       :index=>DateTime.new(2014,5,4,0,0),
                                                       :value=>50
                                                   },
                                                   {
                                                       :index=>DateTime.new(2014,5,4,3,0),
                                                       :value=>60
                                                   }
                                               ])).to match_array(
                                                          []
                                                      )
    end

    it 'should not return a result for a day that does not have a point before it\'s start' do
      expect(SparklineNormalizer.new.normalize([
                                                   {
                                                       :index=>DateTime.new(2014,5,4,2,0),
                                                       :value=>50
                                                   },
                                                   {
                                                       :index=>DateTime.new(2014,5,4,3,0),
                                                       :value=>60
                                                   }
                                               ])).to match_array(
                                                          []
                                                      )
    end
    it 'should return a day if the previous data point is not exactly at midnight' do
      expect(SparklineNormalizer.new.normalize([
                                                   {
                                                       :index=>DateTime.new(2014,5,3,22,0),
                                                       :value=>50
                                                   },
                                                   {
                                                       :index=>DateTime.new(2014,5,4,3,0),
                                                       :value=>50
                                                   },
                                                   {
                                                       :index=>DateTime.new(2014,5,5,0,0),
                                                       :value=>50
                                                   }
                                               ])).to match_array(
                                                          [{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>50}]
                                                      )
    end
    it 'should return a day even if does not have a data point, but there is a preceding and a following one' do
      expect(SparklineNormalizer.new.normalize([
                                                   {
                                                       :index=>DateTime.new(2014,5,3,22,0),
                                                       :value=>50
                                                   },
                                                   {
                                                       :index=>DateTime.new(2014,5,5,22,0),
                                                       :value=>50
                                                   }
                                               ])).to match_array(
                                                          [{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>50}]
                                                      )

      expect(SparklineNormalizer.new.normalize([
                                                   {
                                                       :index=>DateTime.new(2014,5,2,22,0),
                                                       :value=>50
                                                   },
                                                   {
                                                       :index=>DateTime.new(2014,5,5,22,0),
                                                       :value=>50
                                                   }
                                               ])).to match_array(
                                                          [{:index=>DateTime.new(2014,5,3,0,0).to_date,:value=>50},{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>50}]
                                                      )
    end

    it 'should weight data points based on their timespan in the day' do
      expect(SparklineNormalizer.new.normalize([
                                                   {
                                                       :index=>DateTime.new(2014,5,3,22,0),
                                                       :value=>50
                                                   },
                                                   {
                                                       :index=>DateTime.new(2014,5,4,3,0),
                                                       :value=>60
                                                   },
                                                   {
                                                       :index=>DateTime.new(2014,5,4,12,0),
                                                       :value=>200
                                                   },
                                                   {
                                                       :index=>DateTime.new(2014,5,4,18,0),
                                                       :value=>100
                                                   },
                                                   {
                                                       :index=>DateTime.new(2014,5,5,2,0),
                                                       :value=>60
                                                   }
                                               ])).to match_array(
                                                          [{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>113.125}]
                                                      )
    end
  end
end
