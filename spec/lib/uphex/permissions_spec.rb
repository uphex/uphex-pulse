require 'spec_helper'
require 'uphex/permissions'

describe UpHex::Permissions do
  let(:subject) do
    Class.new do
      include UpHex::Permissions
    end.new
  end

  let(:model) do
    Class.new
  end

  context "with no rules" do
    it "returns false" do
      expect(subject.allowed? :action, model).to be_false
    end
  end

  context "with one rule" do
    before do
      subject.allow :action, model
    end

    it "matches that rule with exact action and subject" do
      expect(subject.allowed? :action, model).to be_true
    end

    it "doesn't match with the wrong action" do
      expect(subject.allowed? :something_else, model).to be_false
    end

    it "doesn't match with the wrong subject" do
      expect(subject.allowed? :action, Object).to be_false
    end

    it "matches when the subject is a subclass of the correct class" do
      subclass = Class.new(model)
      expect(subject.allowed? :action, subclass).to be_true
    end

    it "matches when the subject is an instance of the correct class" do
      instance = model.new
      expect(subject.allowed? :action, instance).to be_true
    end

    it "matches when the subject is an instance of the subclass of the correct class" do
      instance = Class.new(model).new
      expect(subject.allowed? :action, instance).to be_true
    end

    it "doesn't match when the subject is an instance of an unrelated class" do
      instance = Class.new.new
      expect(subject.allowed? :action, instance).to be_false
    end
  end

  context "with a block rule" do
    before do
      subject.allow :action, Fixnum do |n|
        n > 0
      end
    end

    it "matches when block matches" do
      expect(subject.allowed? :action, 1).to be_true
    end

    it "doesn't match when block doesn't match" do
      expect(subject.allowed? :action, -1).to be_false
    end
  end

  context "with multiple rules" do
    before do
      subject.allow :action_one, model
      subject.allow :action_two, model
    end

    it "matches included rules" do
      expect(subject.allowed? :action_one, model).to be_true
      expect(subject.allowed? :action_two, model).to be_true
    end
  end
end
