def create_sample_portfolio
  set_csrf_token 'foo'
  post '/portfolios',
       :authenticity_token => 'foo',
       :portfolio => {
           :organization => Organization.all.first.id,
           :name => 'test_portfolio'
       }
end