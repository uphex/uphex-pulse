require 'spec_helper'
require 'uphex/permissions'

describe UpHex::Permissions do
  let(:subject) do
    o = Class.new do
      include UpHex::Permissions
    end

    o.new
  end

  context "with no rules" do
    it "returns false" do
      expect(subject.allowed? :action, Object).to be_false
    end
  end

  context "with one rule" do
    before do
      subject.allow :action, Object
    end

    it "matches that rule" do
      expect(subject.allowed? :action, Object).to be_true
    end

    it "doesn't match a rule with the wrong action" do
      expect(subject.allowed? :something_else, Object).to be_false
    end

    it "doesn't match a rule with the wrong subject" do
      expect(subject.allowed? :action, Fixnum).to be_false
    end
  end

  context "with multiple rules" do
    before do
      subject.allow :action_one, Object
      subject.allow :action_two, Object
    end

    it "matches included rules" do
      expect(subject.allowed? :action_one, Object).to be_true
      expect(subject.allowed? :action_two, Object).to be_true
    end
  end
end
