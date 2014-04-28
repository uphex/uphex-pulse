require 'bundler/setup'
require 'padrino-core/cli/rake'

PadrinoTasks.use(:database)
PadrinoTasks.use(:activerecord)
PadrinoTasks.init

Dir[File.join %w{lib uphex tasks ** *.rake}].each do |f|
  import f
end

begin
  require "rspec/core/rake_task"

  desc "Run all examples"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = %w[--color]
    t.pattern = 'spec/*_spec.rb'
  end
rescue LoadError
end
task :spec => 'ar:abort_if_pending_migrations'

begin
  require "rubocop/rake_task"

  Rubocop::RakeTask.new(:rubocop) do |task|
    task.options = ['--lint']
    task.formatters = ['fuubar']
    task.patterns = %w[app db config lib].map { |prefix| "#{prefix}/**/*.rb" }
  end
rescue LoadError
end


task :test => [:spec, :rubocop]
