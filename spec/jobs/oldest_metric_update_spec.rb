require 'environment_spec_helper'
require 'ostruct'

describe 'OldestMetricUpdate' do

  before do
    ResqueSpec.reset!
  end

  it 'should pick the metric that is updated sooner' do
    create_sample_user
    create_sample_portfolio
    create_sample_metric

    original_metric_id=Metric.all.first.id

    Timecop.freeze(Time.utc(2014,2,28)) do
      OldestMetricUpdate.perform
    end

    MetricUpdate.should have_queued(original_metric_id)
    ResqueSpec.reset!

    metric=Metric.find(original_metric_id)
    metric['updated_at']=Time.now
    metric.save!

    Timecop.freeze(Time.utc(2014,3,1)) do

      new_metric=Metric.create({:provider=>Provider.all.first,:name=>'visitors',:updated_at=>DateTime.new,:analyzed_at=>DateTime.new})

      OldestMetricUpdate.perform

      MetricUpdate.should have_queued(new_metric[:id])
    end
    ResqueSpec.reset!

  end

  it 'should regard last_error_time as updated_at' do
    create_sample_user
    create_sample_portfolio
    create_sample_metric

    original_metric_id=Metric.all.first.id

    Timecop.freeze(Time.utc(2014,2,28)) do
      OldestMetricUpdate.perform
    end

    MetricUpdate.should have_queued(original_metric_id)
    ResqueSpec.reset!

    metric=Metric.find(original_metric_id)
    metric['last_error_time']=Time.now
    metric.save!

    Timecop.freeze(Time.utc(2014,3,1)) do
      new_metric=Metric.create({:provider=>Provider.all.first,:name=>'visitors',:updated_at=>DateTime.new,:analyzed_at=>DateTime.new})

      OldestMetricUpdate.perform

      MetricUpdate.should have_queued(new_metric[:id])
    end
    ResqueSpec.reset!

  end
end