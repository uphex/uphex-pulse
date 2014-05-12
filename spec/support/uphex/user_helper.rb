def create_sample_user
  set_csrf_token 'foo'
  post '/users',
       :authenticity_token => 'foo',
       :user => {
           :name => 'test_user',
           :email => 'test_email',
           :password => 'test_password'
       }
end