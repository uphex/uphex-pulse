module UpHex
  class Pulse < Padrino::Application
    use ActiveRecord::ConnectionAdapters::ConnectionManagement
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers

    helpers do
      def warden
        request.env['warden']
      end

      def session_info(scope=nil)
        scope ? warden.session(scope) : scope
      end

      def authenticated?(scope=nil)
        scope ? warden.authenticated?(scope) : warden.authenticated?
      end

      def authenticate(*args)
        warden.authenticate!(*args)
      end

      def logout(scopes=nil)
        scopes ? warden.logout(scopes) : warden.logout
      end

      def user(scope=nil)
        scope ? warden.user(scope) : warden.user
      end
      alias_method :current_user, :user

      def user=(new_user, opts={})
        warden.set_user(new_user, opts)
      end
      alias_method :current_user=, :user=
    end

    enable :sessions

    ::Warden::Strategies.add :password do
      def valid?
        up = params['user']
        up['email'] || up['password']
      end

      def authenticate!
        u = User.find_by_email params['user']['email']
        m = password_matches?(u.password_hash, params['user']['password']) if u
        if u && m
          success! u
        else
          fail!
          throw(:warden, :message => 'authn.failure')
        end
      end

      def password_matches?(expected, supplied)
        BCrypt::Password.new(expected) == supplied
      end
    end

    use ::Warden::Manager do |manager|
      manager.failure_app = self
      manager.default_strategies :password

      manager.scope_defaults :default,
        :strategies => [:password],
        :action     => 'sessions/auth/unauthenticated'
    end

    ::Warden::Manager.serialize_into_session do |user|
      user.id
    end

    ::Warden::Manager.serialize_from_session do |id|
      User.find_by_id id
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
