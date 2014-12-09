class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user = user
  end

  module AuthorizationPolicy
    attr_reader :ability

    def self.included(base)
      policies.push base
    end

    def self.policies
      @policies ||= []
    end

    def initialize(ability)
      @ability = ability
    end

    def user
      ability.user
    end

    def authenticated?
      !anonymous?
    end

    def anonymous?
      ability.user.nil?
    end

    def applies?
      raise NotImplementedError, "must implement when policy applies"
    end

    def authorize
      raise NotImplementedError, "must describe policy authorizations"
    end

    def apply!
      authorize if applies?
    end
  end

  class UserPolicy
    include Ability::AuthorizationPolicy

    def applies?
      true
    end

    def authorize
      ability.instance_eval do
        can :read, User do |u|
          user == u
        end
      end
    end
  end

  class PortfolioPolicy
    include Ability::AuthorizationPolicy

    def applies?
      true
    end

    def authorize
      ability.instance_eval do
        can [:read,:update,:delete], Portfolio do |p|
          !p.deleted and user.organizations.any?{|organization| organization.portfolios.any?{|portfolio| portfolio.id==p.id}}
        end
        can [:restore], Portfolio do |p|
          p.deleted and user.organizations.any?{|organization| organization.portfolios.any?{|portfolio| portfolio.id==p.id}}
        end
      end
    end
  end

  class OrganizationPolicy
    include Ability::AuthorizationPolicy

    def applies?
      true
    end

    def authorize
      ability.instance_eval do
        can :read, Organization do |o|
          user.organizations.any?{|organization| organization.id==o.id}
        end
      end
    end
  end

  class ProviderPolicy
    include Ability::AuthorizationPolicy

    def applies?
      true
    end

    def authorize
      ability.instance_eval do
        can [:read,:update,:delete], Provider do |p|
          !p.deleted and user.organizations.any?{|organization| organization.portfolios.any?{|portfolio| !portfolio.deleted and portfolio.providers.any?{|provider|provider.id==p.id}}}
        end
      end
    end
  end

  class EventsPolicy
    include Ability::AuthorizationPolicy

    def applies?
      true
    end

    def authorize
      ability.instance_eval do
        can :read, Event do |e|
          !e.metric.provider.deleted and !e.metric.provider.portfolio.deleted and user.organizations.include? e.metric.provider.portfolio.organization
        end
      end
    end
  end
end
