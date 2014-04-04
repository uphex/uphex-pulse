module UpHex
  module Initializers
    module Warden
      def self.registered(app)
        ::Warden::Strategies.add :password, UserPasswordStrategy

        ::Warden::Manager.serialize_into_session do |user|
          user.id
        end

        ::Warden::Manager.serialize_from_session do |id|
          User.find_by_id id
        end

        app.use ::Warden::Manager do |manager|
          manager.failure_app = app
          manager.default_strategies :password

          manager.scope_defaults :default,
            :strategies => [:password],
            :action     => 'sessions/auth/unauthenticated'
        end
      end
    end
  end
end
