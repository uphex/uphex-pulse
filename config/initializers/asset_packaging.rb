require 'sinatra/assetpack'

module UpHex
  module Initializers
    module AssetPackaging
      def self.registered(app)

        app.after do
          if request.url.end_with?('css')
            headers "Content-Type" => "text/css;charset=utf-8"
          end
        end

        app.register Sinatra::AssetPack

        app.assets {
          serve '/js',       from: Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/javascripts'
          serve '/css',      from: Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/stylesheets'
          serve '/fonts',    from: Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/fonts'
          serve '/assets/stylesheets',    from: 'assets/stylesheets'
          serve '/images',    from: 'assets/images'
          serve '/assets/javascripts',    from: 'assets/javascripts'
          serve '/assets',    from: 'assets/fonts'


          js :app, '/js/app.js', [
              '/js/jquery/jquery.min.js',
              '/js/jquery/jquery-migrate.min.js',
              '/js/bootstrap/bootstrap.min.js',
              '/js/theme.js',
              '/assets/javascripts/application.js'
          ]

          css :application, '/css/application.css', [
              '/css/bootstrap/bootstrap.css',
              '/css/light-theme.css',
              '/css/theme-colors.css',
              '/assets/stylesheets/main.css',
              '/assets/stylesheets/application.css'

          ]

          js_compression  :jsmin    # :jsmin | :yui | :closure | :uglify
          css_compression :simple   # :simple | :sass | :yui | :sqwish
        }
      end
    end
  end
end
