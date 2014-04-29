module UpHex
  module Initializers
    module SinatraAssetpack
      def self.registered(app)

        app.after do
          if request.url.end_with?('css')
            headers "Content-Type" => "text/css;charset=utf-8"
          end
        end

        require 'sinatra/assetpack'
        app.register Sinatra::AssetPack

        app.assets {
          serve '/js',     from: Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/javascripts'
          serve '/css',    from: Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/stylesheets'
          serve '/fonts',    from: Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/fonts'
          serve '/public/css',    from: File.dirname(__FILE__)+'/../../public/scss'
          serve '/public/js',    from: File.dirname(__FILE__)+'/../../public/js'
          js :app, '/js/app.js', [
              '/js/jquery/jquery.min.js',
              '/js/jquery/jquery-migrate.min.js',
              '/js/bootstrap/bootstrap.min.js',
              '/js/theme.js',
              '/public/js/test.js'
          ]

          css :application, '/css/application.css', [
              '/css/bootstrap/bootstrap.css',
              '/css/light-theme.css',
              '/css/theme-colors.css',
              '/public/css/test.css'
          ]

          js_compression  :jsmin    # :jsmin | :yui | :closure | :uglify
          css_compression :simple   # :simple | :sass | :yui | :sqwish
        }
      end
    end
  end
end
