require 'bundler/setup'
require 'padrino-core/cli/rake'

PadrinoTasks.use(:database)
PadrinoTasks.use(:activerecord)
PadrinoTasks.init

Dir[File.join %w{lib uphex tasks ** *.rake}].each do |f|
  import f
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :spec => 'ar:abort_if_pending_migrations'
