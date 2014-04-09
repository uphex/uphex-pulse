module UpHex
  module Permissions
    class Rule
      def initialize(action, subject, block)
        @rule_action  = action
        @rule_subject = subject
        @rule_block   = block ||= Proc.new { |subject| true }
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
        @rule_action == action
      end

      def matches_subject?(subject)
        matches_subject_exactly?(subject) ||
          matches_subject_as_instance?(subject) ||
          matches_subject_as_module?(subject)
      end

      def matches_subject_exactly?(subject)
        @rule_subject == subject
      end

      def matches_subject_as_instance?(subject)
        subject.kind_of? @rule_subject
      end

      def matches_subject_as_module?(subject)
        @rule_subject.kind_of?(Module) &&
          subject.kind_of?(Module) &&
          @rule_subject >= subject
      end

      def block_passes?(subject)
        @rule_block && @rule_block.call(subject)
      end
    end
  end
end
