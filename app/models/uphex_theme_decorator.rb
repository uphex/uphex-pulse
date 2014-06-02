class UpHexThemeDecorator
  class ThemeError < RuntimeError; end
  attr_reader :template

  def initialize(template)
    @template = template
  end

  def item_group(&block)
    template.content_tag(:div, :class => 'item-group', &block)
  end

  def paired_item_group_label(label = nil, &block)
    raise ThemeError.new("can't provide both label and block") if label && block_given?
    template.content_tag(:div, label, :class => 'col-md-3 item-label', &block)
  end

  def paired_item_group_value(value = nil, &block)
    raise ThemeError.new("can't provide both value and block") if value && block_given?
    template.content_tag(:div, value, :class => 'col-md-6', &block)
  end
end
