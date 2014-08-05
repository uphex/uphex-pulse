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

          require 'pathname'

          def rel(path)
            Pathname.new(path).relative_path_from(Pathname.new(app.root)).to_s
          end

          serve '/js',       from: rel(Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/javascripts')
          serve '/css',      from: rel(Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/stylesheets')
          serve '/fonts',    from: rel(Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/fonts')
          serve '/assets/stylesheets',    from: rel(File.expand_path('../../../app/assets/stylesheets', __FILE__))
          serve '/images',    from: 'assets/images'
          serve '/assets/javascripts',    from: rel(File.expand_path('../../../app/assets/javascripts', __FILE__))
          serve '/assets',    from: 'assets/fonts'


          js :app, [
              '/js/jquery/jquery.min.js',
              '/js/jquery/jquery-migrate.min.js',
              '/js/bootstrap/bootstrap.min.js',
              '/js/theme.js',
              '/assets/javascripts/vendor/d3.min.js',
              '/assets/javascripts/application.js',
              '/assets/javascripts/sparkline.js'
          ]

          css :application, [
              '/css/bootstrap/bootstrap.css',
              '/css/light-theme.css',
              '/css/theme-colors.css',
              '/assets/stylesheets/main.css',
              '/assets/stylesheets/application.css'
          ]

          js_compression  :uglify    # :jsmin | :yui | :closure | :uglify
          css_compression :simple   # :simple | :sass | :yui | :sqwish
        }
      end
    end
  end
end
