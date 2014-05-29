require 'active_record'
require 'spec/support/active_record'

RSpec.configure do |config|
  # For transactions.
  config.around(:each) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback, "prevent database side effects from leaking"
    end
  end
end
