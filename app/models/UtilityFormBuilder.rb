class UtilityFormBuilder < Padrino::Helpers::FormBuilder::AbstractFormBuilder

  def error_messages_for(field)
    @template.content_tag(:span,
      object.errors[field].join(' '),
      :class=>'help-block'
    )

  end
end