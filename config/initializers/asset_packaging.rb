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
          serve '/theme/js',    from: Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/javascripts'
          serve '/theme/css',   from: Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/stylesheets'
          serve '/theme/fonts', from: Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/fonts'

          serve '/scripts',     from: 'assets/javascripts'
          serve '/stylesheets', from: 'assets/stylesheets'
          serve '/images',      from: 'assets/images'

          css :application, [
            '/stylesheets/application.css'
          ]

          js :forms, '/theme/scripts/forms.js', [
              '/theme/js/jquery/jquery.min.js',
              '/theme/js/jquery/jquery-migrate.min.js',
              '/theme/js/bootstrap/bootstrap.min.js',
              '/theme/js/theme.js',
          ]

          css :forms, '/theme/stylesheets/forms.css', [
              '/theme/css/bootstrap/bootstrap.css',
              '/theme/css/light-theme.css',
              '/theme/css/theme-colors.css',
          ]

          js_compression  :jsmin    # :jsmin | :yui | :closure | :uglify
          css_compression :simple   # :simple | :sass | :yui | :sqwish
        }
      end
    end
  end
end
