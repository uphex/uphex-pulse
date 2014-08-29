class AddNewAnalyticsMetricsToExistingProviders < ActiveRecord::Migration
  def change
    Provider.all.select {
        |provider| provider['provider_name']=='google' and provider.metrics.none? {
          |metric| metric['name']=='impressions'
        }
    }.each { |provider|
      %w(impressions adClicks organicSearches).each do |name|
        Metric.new(:provider => provider, :name => name, :updated_at => DateTime.new, :analyzed_at => DateTime.new).save!
      end
    }
  end
end
