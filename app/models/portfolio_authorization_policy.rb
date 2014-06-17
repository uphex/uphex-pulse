require 'app/models/authorization_policy'

class PortfolioAuthorizationPolicy
  include Ability::AuthorizationPolicy

  def applies?
    true
  end

  def authorize
    ability.can [:read, :update], Portfolio do |p|
      user_portfolios.include? p
    end
  end

  def user_portfolios(user)
    PortfolioRepository.for_user user
  end
end
