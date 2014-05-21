module FormHelper
  def styled_form_for(object, destination, options = {}, &block)
    existing   = options[:class].to_s.split(' ')
    additional = 'form form-horizontal'.split(' ')
    classes    = existing.push(*additional).join(' ')

    form_for object, destination, options.merge(:class => classes, :builder => StyledFormBuilder), &block
  end
end

UpHex::Pulse.helpers FormHelper
