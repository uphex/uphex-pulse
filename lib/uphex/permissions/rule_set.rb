require 'uphex/permissions/rule'

module UpHex
  module Permissions
    class RuleSet < Array
      def relevant_rules(action, subject)
        reverse.select do |rule|
          rule.relevant? action, subject
        end
      end

      def matching_rule?(action, subject)
        !!relevant_rules(action, subject).detect do |rule|
          rule.match? action, subject
        end
      end
    end
  end
end
