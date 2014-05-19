require 'spec_helper'
require 'spec/support/html_matchers'
require 'app/models/styled_form_builder'
require 'active_model'
require 'padrino'

describe StyledFormBuilder do
  let(:template) do
    Class.new do
      include Padrino::Helpers::OutputHelpers
      include Padrino::Helpers::FormHelpers
      include Padrino::Helpers::TagHelpers
    end.new
  end

  let(:model) do
    stub_const 'Model', Class.new { include ActiveModel::Model }
    Model.new
  end

  let(:builder) { described_class.new template, model }

  describe "#styled_* metamethods" do
    it "has a corresponding styled_* method for each field type" do
      c = described_class
      expect(c.field_types).to_not be_empty
      expect(c.field_types - c.instance_methods(true)).to be_empty
    end

    it "adds the 'form-control' class to inputs" do
      expect(builder.styled_text_field :foo).to \
        have_tag('input', :with => { :class => 'form-control' })
    end

    it "populates the input with appropriate attributes" do
      expected_value = 123
      expected_field_name = :foo
      expected_attributes = {
        :value => expected_value.to_s,
        :name => "model[#{expected_field_name}]",
        :id   => "model_#{expected_field_name}",
        :type => 'text',
      }

      expect(builder.styled_text_field expected_field_name, :value => expected_value).to \
        have_tag('input', :with => expected_attributes)
    end
  end

  describe "#messages_for" do
    it "joins errors together" do
      model.class_eval do
        attr_accessor :arbitrary_field
      end

      model.errors[:arbitrary_field] << 'error one'
      model.errors[:arbitrary_field] << 'error two'

      expect(builder.messages_for :arbitrary_field).to \
        have_tag('span',
          :text => 'error one; error two',
          :with => { :class => 'help-block' })
    end
  end
end
