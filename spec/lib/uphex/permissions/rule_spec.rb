require 'spec_helper'
require 'uphex/permissions/rule'

describe UpHex::Permissions::Rule do
  describe "#initialize" do
    let(:block) do
      ->{}
    end

    let(:options) do
      {
        :action => 1,
        :subject => 2,
        :block => block
      }
    end

    it "initializes values from options hash" do
      p = ->{}
      rule = described_class.new options

      expect(rule.action).to eq options[:action]
      expect(rule.subject).to eq options[:subject]
      expect(rule.block).to eq options[:block]
    end

    it "raises an error when there are unused keys" do
      options[:foo] = 3
      expect {described_class.new options}.
        to raise_error ArgumentError, /unrecognized keys/
    end
  end

  describe "#block" do
    it "allows Proc objects" do
      p = ->{}
      expect(subject.block = p).to eq p
    end

    it "doesn't allow non-Proc objects" do
      expect{subject.block = 0}.to raise_error ArgumentError, "not a Proc"
    end
  end
end
