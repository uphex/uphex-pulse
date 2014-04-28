source 'https://rubygems.org'

source 'https://wjqwn44TvBB7by1BXtb1@gem.fury.io/app24628033_heroku_com/'


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
end

# Padrino
gem 'padrino', :git => "git://github.com/padrino/padrino-framework.git"

gem 'uphex-flatty'

gem 'sinatra-assetpack', :require => 'sinatra/assetpack'
gem 'sass'