RSpec.configure do |config|
  require 'shoulda-matchers'
  require 'shoulda/matchers/active_model'
  require 'shoulda/matchers/active_record'

  config.include Shoulda::Matchers::ActiveModel
  config.include Shoulda::Matchers::ActiveRecord
end
