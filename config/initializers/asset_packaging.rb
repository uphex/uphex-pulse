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
          def relative_path(path)
            Pathname.new(path).relative_path_from(Pathname.new(app.root)).to_s
          end

          def app_relative_path(path)
            relative_path(File.expand_path("../../../#{path}", __FILE__))
          end

          serve '/theme/scripts',     from: relative_path(Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/javascripts')
          serve '/theme/stylesheets', from: relative_path(Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/stylesheets')
          serve '/theme/fonts',       from: relative_path(Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/fonts')

          serve '/assets/scripts',     from: relative_path(File.expand_path('../../../app/assets/javascripts', __FILE__))
          serve '/assets/stylesheets', from: relative_path(File.expand_path('../../../app/assets/stylesheets', __FILE__))
          serve '/images',             from: 'assets/images'

          css :application, [
            '/assets/stylesheets/main.css',
            '/assets/stylesheets/application.css',
          ]

          js :forms, [
              '/theme/scripts/jquery/jquery.min.js',
              '/theme/scripts/jquery/jquery-migrate.min.js',
              '/theme/scripts/bootstrap/bootstrap.min.js',
              '/theme/scripts/theme.js',
          ]

          css :forms, [
              '/theme/stylesheets/bootstrap/bootstrap.css',
              '/theme/stylesheets/light-theme.css',
              '/theme/stylesheets/theme-colors.css',
          ]

          js_compression  :jsmin    # :jsmin | :yui | :closure | :uglify
          css_compression :sass     # :simple | :sass | :yui | :sqwish
        }
      end
    end
  end
end
