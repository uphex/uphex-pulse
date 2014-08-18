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
  rescue LoadError => e
    warn "! ignored #{e.class} ⇒ #{e}"
  end
end

def ignore_enoent_errors(&block)
  begin
    yield
  rescue Errno::ENOENT => e
    warn "! ignored #{e.class} ⇒ #{e}"
  end
end

def environment_guard(&block)
  target_env = ENV['RACK_ENV']
  raise ArgumentError, "won't run this task without an environment specified" unless target_env

  legal_environments = %w{development test}

  unless legal_environments.include? target_env
    raise RuntimeError, "environment is \"#{target_env}\", but will only run this task in #{legal_environments}"
  end

  block.call
end

ignore_load_errors do
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :spec => 'ar:abort_if_pending_migrations'

  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop) do |task|
    style_cops = [
      'Style/ConstantName',
      'Style/Tab',
      'Style/TrailingWhitespace'
    ].join(',')

    task.options = [
      '--lint',
      "--only", style_cops,
    ]
    task.formatters = ['fuubar']

    directories = %w[
      app
      db
      config
      lib
      spec
    ]
    task.patterns = directories.map { |prefix| "#{prefix}/**/*.rb" }
  end

  task :test => [:spec, :rubocop]
end

namespace :uphex do
  desc "Drop database and rebuild from scratch"
  task :clean, [:target_env] do |t, args|
    ENV['RACK_ENV'] = target_env = args[:target_env]

    environment_guard do
      tasks = %w{ar:drop ar:create ar:migrate}
      invoker = ->(t) { Rake::Task[t].invoke }

      puts "running tasks #{tasks} on environment [#{target_env}]"
      tasks.each(&invoker)
    end
  end

  desc "Write database.yml"
  task :make_database_config do
    src  = 'config/database.yml.example'
    dest = 'config/database.yml'
    ignore_enoent_errors do
      FileUtils.cp src, dest, :verbose => true
    end
  end

  desc "Write providers.yml"
  task :make_providers_config do
    src  = 'config/providers.yml.example'
    dest = 'config/providers.yml'
    ignore_enoent_errors do
      FileUtils.cp src, dest, :verbose => true
    end
  end

  desc "Perform setup suitable for cloud environments"
  task :deploy => [
    'uphex:make_database_config',
    'uphex:make_providers_config',
    'ar:create',
    'ar:migrate'
  ]

  APP_FILE  = 'config/boot.rb'
  APP_CLASS = 'UpHex::Pulse'
  require 'sinatra/assetpack/rake'
end

task 'db:schema:load' => ['ar:schema:load']
