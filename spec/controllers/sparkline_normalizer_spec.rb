require File.expand_path(File.dirname(__FILE__) + "/../../app/controllers/sparkline_normalizer")
require 'spec/environment_spec_helper'

describe 'SparklineNormalizer' do
  describe 'single day' do
    it 'should work for some data points in a day', :broken => true do
      observations = [
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
      ]
      normalizer = SparklineNormalizer.new(observations)
      expected = [{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>118.125}]
      expect(normalizer.normalized).to match_array(expected)
    end

    it 'should not return a result for a day that does not have a point after it\'s end' do
      observations = [
          {
              :index=>DateTime.new(2014,5,4,0,0),
              :value=>50
          },
          {
              :index=>DateTime.new(2014,5,4,3,0),
              :value=>60
          }
      ]
      normalizer = SparklineNormalizer.new(observations)
      expected = []
      expect(normalizer.normalized).to match_array(expected)
    end

    it 'should not return a result for a day that does not have a point before it\'s start' do
      observations = [
          {
              :index=>DateTime.new(2014,5,4,2,0),
              :value=>50
          },
          {
              :index=>DateTime.new(2014,5,4,3,0),
              :value=>60
          }
      ]
      normalizer = SparklineNormalizer.new(observations)
      expected = []
      expect(normalizer.normalized).to match_array(expected)
    end
    it 'should return a day if the previous data point is not exactly at midnight' do
      observations = [
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
      ]
      normalizer = SparklineNormalizer.new(observations)
      expected = [{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>50}]
      expect(normalizer.normalized).to match_array(expected)
    end
    it 'should return a day even if does not have a data point, but there is a preceding and a following one' do
      observations = [
          {
              :index=>DateTime.new(2014,5,3,22,0),
              :value=>50
          },
          {
              :index=>DateTime.new(2014,5,5,22,0),
              :value=>50
          }
      ]
      normalizer = SparklineNormalizer.new(observations)
      expected = [{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>50}]
      expect(normalizer.normalized).to match_array(expected)

      observations = [
          {
              :index=>DateTime.new(2014,5,2,22,0),
              :value=>50
          },
          {
              :index=>DateTime.new(2014,5,5,22,0),
              :value=>50
          }
      ]
      normalizer = SparklineNormalizer.new(observations)
      expected = [{:index=>DateTime.new(2014,5,3,0,0).to_date,:value=>50},{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>50}]
      expect(normalizer.normalized).to match_array(expected)
    end

    it 'should weight data points based on their timespan in the day' do
      observations = [
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
      ]
      normalizer = SparklineNormalizer.new(observations)
      expected = [{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>118.75}]
      expect(normalizer.normalized).to match_array(expected)
    end
    it 'should work for non sorted data', :broken => true do
      observations = [

          {
              :index=>DateTime.new(2014,5,4,3,0),
              :value=>60
          },
          {
              :index=>DateTime.new(2014,5,4,0,0),
              :value=>50
          },
          {
              :index=>DateTime.new(2014,5,5,0,0),
              :value=>60
          },
          {
              :index=>DateTime.new(2014,5,4,12,0),
              :value=>200
          },
          {
              :index=>DateTime.new(2014,5,4,18,0),
              :value=>100
          }
      ]
      normalizer = SparklineNormalizer.new(observations)
      expected = [{:index=>DateTime.new(2014,5,4,0,0).to_date,:value=>118.125}]
      expect(normalizer.normalized).to match_array(expected)
    end

    it 'should return an empty array if called with an empty array' do
      observations = []
      normalizer = SparklineNormalizer.new(observations)
      expected = []
      expect(normalizer.normalized).to match_array(expected)
    end
  end
end
