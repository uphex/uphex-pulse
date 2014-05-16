module UpHex
  module Initializers
    module CompassAssets
      def self.registered(app)
        require 'sass/plugin/rack'

        app.use Sass::Plugin::Rack
        Sass::Plugin.on_updating_stylesheet do |t_in, t_out|
          app.logger.debug "compiling:\nin: #{t_in}\nout: #{t_out}"
        end

        Compass.configuration do |config|
          config.project_path         = Padrino.root
          config.project_type         = :stand_alone
          config.output_style         = :compressed
          config.preferred_syntax     = :scss

          config.http_path            = "/"
          config.sass_dir             = "app/assets/stylesheets"
          config.images_dir           = "app/assets/images"
          config.http_images_path     = "/images"
          config.css_dir              = "public/stylesheets"
          config.javascripts_dir      = "public/javascripts"

          config.add_import_path 'app/assets/stylesheets'

          config.on_stylesheet_error do |f, m|
            puts "---- error in #{f}"
            puts m
          end
        end

        Compass.configure_sass_plugin!
        Compass.handle_configuration_change!

        app.logger.devel "Initializing Compass with options: #{Compass.sass_engine_options}"
        app.set :sass, Compass.sass_engine_options
        app.set :scss, Compass.sass_engine_options
      end
    end
  end
end
