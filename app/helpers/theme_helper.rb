module ThemeHelper
  def theme_builder
    @theme_builder ||= UpHexThemeDecorator.new(self)
  end

  def with_theme_builder(&block)
    output = capture_html(theme_builder, &block)
    block_is_template?(block) ? concat_content(output) : output
  end
end

UpHex::Pulse.helpers ThemeHelper
