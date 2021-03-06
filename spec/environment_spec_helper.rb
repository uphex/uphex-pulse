require 'spec_helper'
require 'spec/support/active_record_transactions'

# Load Padrino.
RACK_ENV = 'test' unless defined?(RACK_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

# Require support files.
Dir[File.join %w{spec support padrino ** *.rb}].each do |f|
  require f
end

RSpec::Matchers.define :be_routable do
  match do |verb_to_path_map|
    begin
      # compile Padrino's routing information
      Padrino.application.call(Rack::MockRequest.env_for("/"))
    end
    path = verb_to_path_map.values.first
    method = verb_to_path_map.keys.first.to_s.upcase
    @routed_to = Padrino.mounted_apps.map(&:app_obj).
      map{|a| a.router.recognize(Rack::MockRequest.env_for(path, :method => method))}.first
    @routed_to.first
  end

  failure_message_when_negated do |path|
    "expected #{path.inspect} not to be routable, but it routes to #{@routed_to.inspect}"
  end
end
