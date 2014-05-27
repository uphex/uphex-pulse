require 'spec_helper'
require 'spec/support/html_matchers'
require 'padrino'
require 'app/models/styled_form_builder'
require 'active_model'

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
      methods = c.field_types.map { |f| "styled_#{f}".to_sym }

      expect(methods).to_not be_empty
      expect(methods - c.instance_methods(true)).to be_empty
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

  context "with an arbitrary ActiveModel" do
    before(:each) do
      model.class_eval do
        attr_accessor :arbitrary_field
      end
    end

    describe "#styled_*_block" do
      it "works inside a form block" do
        form_html = template.form_for(Model.new, '/arbitrary_url', :builder => StyledFormBuilder) do |f|
          f.styled_text_field_block :arbitrary_field
        end

        expect(form_html).to have_tag('form') do
          with_tag('div', :with => { :class => 'form-group' }) do
            with_tag 'label', :with => { :for => 'model_arbitrary_field' }
            with_tag 'input', :with => { :id  => 'model_arbitrary_field' }
            with_tag 'span',  :with => { :class => 'help-block' }
          end
        end
      end

      it "has a corresponding styled_*_block method for each field type" do
        c = described_class
        methods = c.field_types.map { |f| "styled_#{f}_block".to_sym }

        expect(methods).to_not be_empty
        expect(methods - c.instance_methods(true)).to be_empty
      end

      it "generates a div enclosing other form elements" do
        expect(builder.styled_text_field_block :arbitrary_field).to \
          have_tag('div', :with => { :class => 'form-group' }) do
            with_tag 'label', :with => { :for => 'model_arbitrary_field' }
            with_tag 'input', :with => { :id  => 'model_arbitrary_field' }
            with_tag 'span',  :with => { :class => 'help-block' }
          end
      end
    end

    describe "#styled_label_for" do
      it "adds a label for a field with the appropriate class" do
        expect(builder.styled_label_for :arbitrary_field).to \
          have_tag('label',
            :text => /Arbitrary field:/,
            :with => {
              :for   => "model_arbitrary_field",
              :class => "col-md-3 control-label"
            }
          )
      end
    end

    describe "#styled_messages_for" do
      it "joins errors together for a field with the appropriate class" do
        model.errors[:arbitrary_field] << 'error one'
        model.errors[:arbitrary_field] << 'error two'

        expect(builder.styled_messages_for :arbitrary_field).to \
          have_tag('span',
            :text => 'error one; error two',
            :with => { :class => 'help-block' }
          )
      end
    end
  end
end
