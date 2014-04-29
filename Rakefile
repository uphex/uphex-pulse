require 'bundler/setup'
require 'padrino-core/cli/rake'

PadrinoTasks.use(:database)
PadrinoTasks.use(:activerecord)
PadrinoTasks.init

Dir[File.join %w{lib uphex tasks ** *.rake}].each do |f|
  import f
end

def ignore_load_errors(&block)
  begin
    yield
  rescue LoadError
  end
end

ignore_load_errors do
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :spec => 'ar:abort_if_pending_migrations'

  require 'rubocop/rake_task'
  Rubocop::RakeTask.new(:rubocop) do |task|
    task.options = ['--lint']
    task.formatters = ['fuubar']
    task.patterns = %w[app db config lib].map { |prefix| "#{prefix}/**/*.rb" }
  end

  task :test => [:spec, :rubocop]
end

namespace :uphex do
  desc "Write database.yml"
  task :make_database_config do
    src  = 'config/database.yml.example'
    dest = 'config/database.yml'
    FileUtils.cp src, dest, :verbose => true
  end

  task :deploy => ['uphex:make_database_config', 'ar:create', 'ar:migrate']
end
