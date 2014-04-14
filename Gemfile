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
gem 'activerecord', :require => 'active_record'

# Extensions
gem 'activesupport', :require => false

# Database
gem 'pg'

# Authentication
gem 'warden'

# Encryption
gem 'bcrypt-ruby'

gem 'sinatra'
gem 'haml'
gem 'compass'
gem 'sinatra-support'
gem 'coffee-script'
gem 'sinatra-assetpack'

gem 'uphex-flatty', git: 'git@github.com:uphex/uphex-flatty.git', branch: 'serve-flatty-assets'

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
