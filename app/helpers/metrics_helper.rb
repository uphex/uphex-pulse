module MetricsHelper

  def full_metric_name(metric)
    provider_name=metric.provider.name
    portfolio_name=metric.provider.portfolio.name
    organization_name=metric.provider.portfolio.organization.name
    [organization_name,portfolio_name,provider_name,metric.name].join('/')
  end

  def deleted?(metric)
    metric.provider.deleted? or metric.provider.portfolio.deleted?
  end
end

UpHex::Pulse.helpers MetricsHelper
