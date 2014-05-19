require 'padrino-helpers/form_builder/abstract_form_builder'

class StyledFormBuilder < Padrino::Helpers::FormBuilder::AbstractFormBuilder
  def styled_label_for(field, options = {}, &block)
    classes = add_classes_to_string options[:class], 'col-md-2 control-label'
    label field, options.merge(:class => classes), &block
  end

  def styled_messages_for(field, options = {}, &block)
    classes = add_classes_to_string options[:class], 'help-block'

    template.content_tag(:span,
      object.errors[field].join('; '),
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
        ].join.html_safe
      }

      classes = add_classes_to_string options[:class], 'form-group'
      template.content_tag(:div, options.merge(:class => classes), &block)
    end

    define_method "styled_#{f}", ->(field, options = {}, &block) do
      classes = add_classes_to_string options[:class], 'form-control'

      send f, field, options.merge(:class => classes), &block
    end
  end

  def add_classes_to_string(string_of_classes, classes_to_add)
    additional = classes_to_add.split(' ')
    existing   = string_of_classes.to_s.split(' ')

    existing.push(*additional).join(' ')
  end
end
