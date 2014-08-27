module MetricsHelper

  def full_metric_name(metric)
    metric.provider.portfolio.organization.name+'/'+metric.provider.portfolio.name+'/'+metric.provider.name+'/'+metric.name
  end

  def deleted?(metric)
    metric.provider.deleted? or metric.provider.portfolio.deleted?
  end
end

UpHex::Pulse.helpers MetricsHelper
