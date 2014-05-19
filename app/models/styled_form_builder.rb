require 'padrino-helpers/form_builder/abstract_form_builder'

class StyledFormBuilder < Padrino::Helpers::FormBuilder::AbstractFormBuilder
  def messages_for(field, options = {}, &block)
    template.content_tag(:span,
      object.errors[field].join('; '),
      options.merge(:class => 'help-block'),
      &block
    )
  end

  def styled_input_classes
    @styled_input_classes ||= styled_input_classes_hash
  end

  self.field_types.each do |f|
    define_method "styled_#{f}", ->(*args, &block) do
      raise ArgumentError, "couldn't translate arguments for a #styled_#{f} to ##{f}" if args.size > 2

      field_name   = args[0]
      options_hash = args[1] || {}
      options_hash[:class] = [options_hash[:class], *styled_input_classes[f]].compact.join(' ')

      new_args = [field_name, options_hash, args[2..-1]].
        compact.
        reject { |o| o.empty? }

      send f, *new_args, &block
    end
  end

  private

  def styled_input_classes_hash
    self.class.field_types.reduce({}) do |hash, field_type|
      hash.tap do |hash|
        hash[field_type.to_sym] = %w{form-control}
      end
    end
  end
end
