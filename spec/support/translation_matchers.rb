RSpec::Matchers.define :have_message do |expected_key|
  require 'cgi'

  def to_html_message(key)
    CGI.escapeHTML I18n.t key
  end

  match do |actual|
    actual.include? to_html_message expected_key
  end

  failure_message do |actual|
    message = to_html_message expected_key
    %|expected that #{actual} would contain message: #{message}|
  end

  description do
    %|contains the message for the key "#{expected_key}"|
  end
end
