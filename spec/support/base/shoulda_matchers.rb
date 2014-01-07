RSpec.configure do |config|
  require 'shoulda-matchers'
  require 'shoulda/matchers/active_model'
  config.include Shoulda::Matchers::ActiveModel
end
