require 'active_record'
require 'yaml'
require 'erb'
require 'spec/support/active_record_transactions'

YAML.load(ERB.new(File.read File.join('.', 'config', 'database.yml')).result).each { |name, hash|
  symbolized_hash = hash.each_with_object({}) do |(k, v), h|
    h[k.to_sym] = v
  end
  ActiveRecord::Base.configurations[name.to_sym] = symbolized_hash
}

ActiveRecord::Base.establish_connection(
  ActiveRecord::Base.configurations[(ENV['RACK_ENV'] || 'test').to_sym]
)

I18n.enforce_available_locales = true
