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
end
