def stacked_middlewares(app, args)
  require Padrino.root('config/boot.rb')
  app_obj = app.app_obj
  instance = app_obj.new!
  build = app_obj.build(instance)
  stacks = build.instance_variable_get(:@use)
  middlewares = stacks.map{|stack| stack[instance].class}
  middlewares.reject! { |m| m.to_s !~ /#{args.query}/ } if args.query.present?
  return if Padrino.middleware.empty? && middlewares.empty?
  shell.say "\nApplication: #{app.app_class}", :yellow
  Padrino.middleware.each do |m|
    shell.say("    #{m.first}")
  end
  middlewares.each do |m|
    shell.say("    #{m}")
  end
end
 
desc "Displays a listing of the Rack middleware stack within a project, optionally only those matched by [query]"
task :middleware, [:query] => :environment do |t, args|
  Padrino.mounted_apps.each do |app|
    stacked_middlewares(app, args)
  end
end
 
desc "Displays a listing of the Rack middleware stack a given app [app]"
namespace :middleware do
  task :app, [:app] => :environment do |t, args|
    app = Padrino.mounted_apps.find { |app| app.app_class == args.app }
    stacked_middlewares(app, args) if app
  end
end
