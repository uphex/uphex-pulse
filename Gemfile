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
gem 'sass'

# Custom styles
gem 'uphex-flatty',
  :git => "git@github.com:uphex/uphex-flatty.git"

# Extensions
gem 'activesupport', :require => false

# Database
gem 'pg'

# Authentication
gem 'warden'

# Authorization
gem 'cancan'

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

  # Code enforcement.
  gem 'rubocop', :require => false

  gem 'resque_spec'
  gem 'timecop'
end

# Padrino
gem 'padrino', :git => "git://github.com/padrino/padrino-framework.git"

# Asset management
gem 'sinatra-assetpack'

#OAuth
gem 'rack-oauth2','1.0.8'
gem 'oauth'
gem 'uphex-prototype-cynosure','0.0.10', :git => 'git@github.com:uphex/uphex-prototype-cynosure.git'

#Scheduling
gem 'resque'
gem 'resque-scheduler'

#Estimation
gem 'uphex-estimation',
    :git => "git@github.com:uphex/uphex-prototype-estimation.git"

gem 'uglifier'