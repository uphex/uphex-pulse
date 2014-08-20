def create_sample_metric
  set_csrf_token 'foo'
  provider=Provider.create({
                               :portfolios_id => Portfolio.all.first.id,
                               :profile_id => 'test_profile_id1',
                               :provider_name => 'google',
                               :refresh_token => 'refresh_token',
                               :access_token => 'access_token',
                               :userid => User.all.first.id,
                               :name => 'account/test_profile',
                               :expiration_date => DateTime.now+100.days
                           })
  Metric.create({
                    :provider => provider,
                    :name => 'visits',
                    :updated_at => DateTime.new,
                    :analyzed_at => DateTime.new
                })
end