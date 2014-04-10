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

require 'rubocop/rake_task'
Rubocop::RakeTask.new(:rubocop) do |task|
  task.options = ['--lint']
  task.formatters = ['fuubar']
end

task :test => [:spec, :rubocop]
