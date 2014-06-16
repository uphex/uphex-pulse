require 'app/models/authorization_policy'

class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user = user
    policies.each { |p| p.apply! }
  end

  def policies
    @concrete_policies ||= AuthorizationPolicy.policies.map do |policy_class|
      policy_class.new(self)
    end
  end
end
