require 'padrino-helpers/form_builder/abstract_form_builder'
require 'active_support/inflector'

class StyledFormBuilder < Padrino::Helpers::FormBuilder::AbstractFormBuilder
  class Options < Hash
    def with_help_message(help_message)
      if help_message
        self[:message_options] ||= self.class.new
        self[:message_options][:help_message] = help_message
      end
      self
    end

    def with_label_caption(caption)
      if caption
        self[:label_options] ||= self.class.new
        self[:label_options][:caption] = caption
      end
      self
    end

    def with_field_placeholder(placeholder)
      if placeholder
        self[:field_options] ||= self.class.new
        self[:field_options][:placeholder] = placeholder
      end
      self
    end

    def with_options_for(key)
      caption_key     = "attributes.#{key}"
      help_key        = "messages.#{key}.help"
      placeholder_key = "messages.#{key}.placeholder"

      caption = I18n.t(caption_key, :raise => true) rescue default_caption_key_for(caption_key)
      caption = "#{caption.to_s.humanize}:"

      help    = I18n.t(help_key, :raise => true) rescue nil

      placeholder = I18n.t(placeholder_key, :raise => true) rescue nil

      self.
        with_label_caption(caption).
        with_help_message(help).
        with_field_placeholder(placeholder)
    end

    def default_caption_key_for(key)
      key.split('.').compact.last || ''
    end
  end

  def new_hash
    Options.new
  end

  def errors_for(field)
    object.respond_to?(:errors) ? object.errors[field] : []
  end

  def styled_label_for(field, options = {}, &block)
    classes = add_classes_to_string options[:class], 'col-md-3 control-label'

    label field, options.merge(:class => classes), &block
  end

  def styled_error_list_for(field)
    errors = errors_for(field)

    if !errors.empty?
      errors_for(field).map do |error|
        %{&mdash; <span>#{error}</span>}.html_safe
      end.join('<br>')
    end
  end

  def styled_field_messages_for(field, options = {}, &block)
    classes = add_classes_to_string options[:class], 'col-md-4 help-block box-no-padding'
    shared_options = options.dup

    help_message_content  = shared_options.delete(:help_message)
    error_message_content = styled_error_list_for field

    content = [
      help_message_content,
      error_message_content
    ].reject(&:blank?).join('<br>').html_safe

    inner_content = template.content_tag(:small, content, &block)

    template.content_tag(:div,
      inner_content,
      options.merge(:class => classes)
    )
  end

  def styled_form_actions_block(&block)
    template.content_tag(:div, :class => 'form-actions') do
      template.content_tag(:div, :class => 'row') do
        template.content_tag(:div, :class => 'col-md-10 col-md-offset-3', &block)
      end
    end
  end

  def styled_form_action(action, options = {}, &block)
    action_style = (options.delete(:primary) ? 'btn btn-primary' : 'btn')

    template.content_tag(:input,
      nil,
      options.merge(
        :value => action,
        :class => action_style,
        :type  => 'submit'
      ),
      &block
    )
  end

  self.field_types.each do |f|
    define_method "styled_translated_#{f}_block", ->(field, options = {}, &block) do
      name = object.class.name.demodulize.underscore
      key  = "#{name}.#{field}"

      augmented_options = Options.new.merge(options.dup)
      augmented_options.with_options_for(key)

      send("styled_#{f}_block", field, augmented_options, &block)
    end

    define_method "styled_#{f}_block", ->(field, options = {}, &block) do
      shared_options  = options.dup
      label_options   = shared_options.delete(:label_options)   || {}
      field_options   = shared_options.delete(:field_options)   || {}
      message_options = shared_options.delete(:message_options) || {}

      block ||= Proc.new {
        [
          styled_label_for(field,    shared_options.merge(label_options)),
          send("styled_#{f}", field, shared_options.merge(field_options).merge(message_options)),
          styled_field_messages_for(field, shared_options.merge(message_options)),
        ].reject(&:blank?).join.html_safe
      }

      group_string = errors_for(field).any? ? 'form-group has-error' : 'form-group'

      classes = add_classes_to_string shared_options[:class], group_string
      template.content_tag(:div, shared_options.merge(:class => classes), &block)
    end

    define_method "styled_#{f}", ->(field, options = {}, &block) do
      classes = add_classes_to_string options[:class], 'form-control'

      template.content_tag(:div, {:class => 'col-md-5'}) {
        [
          send(f, field, options.merge(:class => classes), &block),
        ].reject(&:blank?).join.html_safe
      }
    end
  end

  def add_classes_to_string(string_of_classes, classes_to_add)
    additional = classes_to_add.split(' ')
    existing   = string_of_classes.to_s.split(' ')

    existing.push(*additional).join(' ')
  end
end
