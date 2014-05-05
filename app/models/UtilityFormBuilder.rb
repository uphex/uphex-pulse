class UtilityFormBuilder < Padrino::Helpers::FormBuilder::AbstractFormBuilder
  def error_messages_for(field)
    object.errors[field].join(' ')
  end
end