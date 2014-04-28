module UpHex
  class Pulse < Padrino::Application
    use ActiveRecord::ConnectionAdapters::ConnectionManagement
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers

    enable :sessions
    register UpHex::Initializers::Warden

    after do
      if request.url.end_with?('css')
        headers "Content-Type" => "text/css;charset=utf-8"
      end
    end

    ##
    # Caching support.
    #
    # register Padrino::Cache
    # enable :caching
    #
    # You can customize caching store engines:
    #
    # set :cache, Padrino::Cache::Store::Memcache.new(::Memcached.new('127.0.0.1:11211', :exception_retry_limit => 1))
    # set :cache, Padrino::Cache::Store::Memcache.new(::Dalli::Client.new('127.0.0.1:11211', :exception_retry_limit => 1))
    # set :cache, Padrino::Cache::Store::Redis.new(::Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0))
    # set :cache, Padrino::Cache::Store::Memory.new(50)
    # set :cache, Padrino::Cache::Store::File.new(Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
    #

    ##
    # Application configuration options.
    #
    # set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true    # Shows a stack trace in browser (default for development)
    # set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
    # set :public_folder, 'foo/bar' # Location for static assets (default root/public)
    # set :reload, false            # Reload application files (default in development)
    # set :default_builder, 'foo'   # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, 'bar'       # Set path for I18n translations (default your_apps_root_path/locale)
    # disable :sessions             # Disabled sessions by default (enable if needed)
    # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

    require 'sinatra/assetpack'
    register Sinatra::AssetPack

    assets {
      serve '/js',     from: Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/javascripts'
      serve '/css',    from: Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/stylesheets'
      serve '/fonts',    from: Gem::Specification.find_by_name("uphex-flatty").gem_dir+'/assets/fonts'
      serve '/public/css',    from: File.dirname(__FILE__)+'/../public/scss'
      serve '/public/js',    from: File.dirname(__FILE__)+'/../public/js'
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

    ##
    # You can configure for a specified environment like:
    #
    #   configure :development do
    #     set :foo, :bar
    #     disable :asset_stamp # no asset timestamping for dev
    #   end
    #

    ##
    # You can manage errors like:
    #
    #   error 404 do
    #     render 'errors/404'
    #   end
    #
    #   error 505 do
    #     render 'errors/505'
    #   end
    #
  end
end
