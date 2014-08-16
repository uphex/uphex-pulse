module UpHex
  module RSpec
    module ValidationMatcherHelper
      # context "foo" do
      #   validation_spec_for(:bar, :baz)
      #   # --> it { expect(subject).to validate_bar_of(:baz) }
      # end
      def validation_spec_for(kind, field, &block)
        method_name = case kind
        when :inclusion
          "ensure_inclusion_of"
        else
          "validate_#{kind}_of"
        end

        it {
          expect(subject).to(
            block_given? ?
            block.call(send(method_name, field)) :
            send(method_name, field)
          )
        }
      end

      # context "foo" do
      #   association_spec_for(:bar, :baz)
      #   # --> it { expect(subject).to bar(:baz) }
      # end
      def association_spec_for(kind, field, &block)
        it {
          expect(subject).to(
            block_given? ?
            block.call(send(kind, field)) :
            send(kind, field)
          )
        }
      end
    end
  end
end

RSpec.configure do |config|
  require 'shoulda-matchers'
  require 'shoulda/matchers/active_model'
  require 'shoulda/matchers/active_record'

  config.include Shoulda::Matchers::ActiveModel
  config.include Shoulda::Matchers::ActiveRecord

  config.extend UpHex::RSpec::ValidationMatcherHelper
end
