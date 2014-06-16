class UserAuthorizationPolicy
  include Ability::AuthorizationPolicy

  def applies?
    true
  end

  def authorize
    ability.can :read, User do |u|
      ability.user == u
    end
  end
end
