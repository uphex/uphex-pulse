require 'uphex/permissions/rule'
require 'uphex/permissions/rule_set'

module UpHex
  module Permissions
    def rules
      @_rules ||= RuleSet.new
    end

    def allow(action, subject, &block)
      rules.push Rule.new(action, subject, block)
    end

    def allowed?(action, subject)
      rules.matching_rule? action, subject
    end
  end
end
