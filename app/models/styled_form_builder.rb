require 'padrino-helpers/form_builder/abstract_form_builder'

class StyledFormBuilder < Padrino::Helpers::FormBuilder::AbstractFormBuilder
  def errors_for(field)
    object.respond_to?(:errors) ? object.errors[field] : []
  end

  def styled_label_for(field, options = {}, &block)
    classes = add_classes_to_string options[:class], 'col-md-2 control-label'
    label field, options.merge(:class => classes), &block
  end

  def styled_messages_for(field, options = {}, &block)
    classes = add_classes_to_string options[:class], 'help-block'

    template.content_tag(:span,
      errors_for(field).join('; '),
      options.merge(:class => classes),
      &block
    )
  end

  self.field_types.each do |f|
    define_method "styled_#{f}_block", ->(field, options = {}, &block) do
      block ||= Proc.new {
        [
          styled_label_for(field, options),
          send("styled_#{f}", field, options),
          styled_messages_for(field, options),
        ].reject { |o| o.blank? }.join.html_safe
      }

      group_string = errors_for(field).any? ? 'form-group has-error' : 'form-group'

      classes = add_classes_to_string options[:class], group_string
      template.content_tag(:div, options.merge(:class => classes), &block)
    end

    define_method "styled_#{f}", ->(field, options = {}, &block) do
      classes = add_classes_to_string options[:class], 'form-control'

      template.content_tag(:div, {:class => 'col-md-5'}) {
        send f, field, options.merge(:class => classes), &block
      }
    end
  end

  def add_classes_to_string(string_of_classes, classes_to_add)
    additional = classes_to_add.split(' ')
    existing   = string_of_classes.to_s.split(' ')

    existing.push(*additional).join(' ')
  end
end
