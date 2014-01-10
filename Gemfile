source 'https://rubygems.org'

# Distribute your app as a gem
# gemspec

# Server
# gem 'trinidad', :platform => 'jruby'

# Optional JSON codec (faster performance)
# gem 'oj'

# Project requirements
gem 'rake'

# Component requirements
gem 'thin'
gem 'haml'
gem 'activerecord', :require => 'active_record'

# Database
gem 'pg'

# Authentication
gem 'warden'

# Encryption
gem 'bcrypt-ruby'

# Test requirements
group :test do
  gem 'byebug'
  gem 'rspec'
  gem 'rack-test',
    :git => 'git@github.com:brynary/rack-test.git'
  gem 'shoulda-matchers',
    :git => 'git@github.com:thoughtbot/shoulda-matchers.git'
end

# Padrino
gem 'padrino', :git => "git://github.com/padrino/padrino-framework.git"
