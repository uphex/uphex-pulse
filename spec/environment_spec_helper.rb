require 'spec_helper'

# Load Padrino.
PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

# Require support files.
Dir[File.join %w{spec support padrino ** *.rb}].each do |f|
  require f
end

RSpec.configure do |config|
  # For transactions.
  config.around(:each) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback, "prevent database side effects from leaking"
    end
  end
end
