module UpHex
  module Permissions
    class Rule
      attr_accessor :action
      attr_accessor :subject
      attr_accessor :block

      def initialize(options = {})
        options = options.dup

        self.action     = options.delete :action
        self.subject    = options.delete :subject
        self.block      = options.delete(:block) || Proc.new { |subject| true }

        if !options.keys.empty?
          raise ArgumentError.new "unrecognized keys: #{options.keys}"
        end
      end

      def block=(callable)
        raise ArgumentError.new "not a Proc" unless callable.is_a? Proc
        @block = callable
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
        self.action == action
      end

      def matches_subject?(subject)
        matches_subject_exactly?(subject) ||
          matches_subject_as_instance?(subject) ||
          matches_subject_as_module?(subject)
      end

      def matches_subject_exactly?(subject)
        self.subject == subject
      end

      def matches_subject_as_instance?(subject)
        subject.kind_of? self.subject
      end

      def matches_subject_as_module?(subject)
        self.subject.kind_of?(Module) &&
          subject.kind_of?(Module) &&
          self.subject >= subject
      end

      def block_passes?(subject)
        self.block && self.block.call(subject)
      end
    end
  end
end
