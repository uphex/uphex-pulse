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

  describe StyledFormBuilder::Options do
    let(:options_hash) { described_class.new }

    it "returns a default caption when translation fails" do
      key  = "invalid.key_value"
      output_hash = options_hash.with_options_for(key)

      expected_message = "Key value:"

      expect(output_hash.with_options_for(key)).to include(
        { :label_options => { :caption => expected_message } }
      )
    end
  end

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

    describe "#styled_translated_*_block" do
      it "does a key lookup for associated names" do
        field_name      = 'arbitrary_field'
        caption_key     = "attributes.model.#{field_name}"
        help_key        = "messages.model.#{field_name}.help"
        placeholder_key = "messages.model.#{field_name}.placeholder"

        expect(I18n).to receive(:t).with(caption_key, anything())
        expect(I18n).to receive(:t).with(help_key, anything())
        expect(I18n).to receive(:t).with(placeholder_key, anything())

        builder.styled_translated_text_field_block(:arbitrary_field)
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
            with_tag 'div',  :with => { :class => 'help-block' }
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
            with_tag 'div',  :with => { :class => 'help-block' }
          end
      end

      context "with component-specific options" do
        let(:expected_options) do
          { :class => 'arbitrary-class' }
        end

        it "passes label options to just the label" do
          opts = { :label_options => expected_options }

          expect(builder.styled_text_field_block :arbitrary_field, opts).to \
            have_tag('div') do
              with_tag 'label',                       :with    => expected_options
              with_tag 'input#model_arbitrary_field', :without => expected_options
              with_tag 'div.help-block',             :without => expected_options
          end
        end
        it "passes field options to just the input field" do
          opts = { :field_options => expected_options }

          expect(builder.styled_text_field_block :arbitrary_field, opts).to \
            have_tag('div') do
              with_tag 'label',                       :without => expected_options
              with_tag 'input#model_arbitrary_field', :with    => expected_options
              with_tag 'div.help-block',             :without => expected_options
          end
        end
        it "passes message options to just the message block" do
          opts = { :message_options => expected_options }

          expect(builder.styled_text_field_block :arbitrary_field, opts).to \
            have_tag('div') do
              with_tag 'label',                       :without => expected_options
              with_tag 'input#model_arbitrary_field', :without => expected_options
              with_tag 'div.help-block',             :with    => expected_options
          end
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

    describe "#styled_field_messages_for" do
      it "joins errors together and formats for a field with the appropriate class" do
        model.errors[:arbitrary_field] << 'error one'
        model.errors[:arbitrary_field] << 'error two'

        expect(builder.styled_field_messages_for :arbitrary_field).to \
          have_tag('div',
            :text => /error one(.*)error two/,
            :with => { :class => 'help-block' }
          )
      end
    end
  end
end
