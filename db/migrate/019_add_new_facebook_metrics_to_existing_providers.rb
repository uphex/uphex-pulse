class AddNewFacebookMetricsToExistingProviders < ActiveRecord::Migration
  def change
    Provider.all.select {
        |provider| provider['provider_name']=='facebook' and provider.metrics.none? {
          |metric| metric['name']=='pageImpressionsPaid'
      }
    }.each { |provider|
      %w(pageImpressionsPaid pagePostsImpressionsPaid postImpressionsPaid postImpressionsFanPaid postVideoCompleteViewsPaid postVideoViewsPaid).each do |name|
        Metric.new(:provider => provider, :name => name, :updated_at => DateTime.new, :analyzed_at => DateTime.new).save!
      end
    }
  end
end