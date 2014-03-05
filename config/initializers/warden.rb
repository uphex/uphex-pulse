::Warden::Strategies.add :password, UserPasswordStrategy

::Warden::Manager.serialize_into_session do |user|
  user.id
end

::Warden::Manager.serialize_from_session do |id|
  User.find_by_id id
end

Padrino.application do
  use ::Warden::Manager do |manager|
    manager.failure_app = self
    manager.default_strategies :password

    manager.scope_defaults :default,
      :strategies => [:password],
      :action     => 'sessions/auth/unauthenticated'
  end
end
