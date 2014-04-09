module UpHex
  module Permissions
    class Rule
      def initialize(action, subject, block)
        @action  = action
        @subject = subject
        @block   = block ||= Proc.new { |subject| true }
      end

      def relevant?(action, subject)
        matches_action?(action) &&
          matches_subject?(subject)
      end

      def match?(action, subject)
        matches_action?(action) &&
          matches_subject?(subject) &&
          block_passes?(subject)
      end

      def matches_action?(action)
        @action == action
      end

      def matches_subject?(subject)
        @subject == subject
      end

      def block_passes?(subject)
        @block && @block.call(subject)
      end
    end
  end
end
