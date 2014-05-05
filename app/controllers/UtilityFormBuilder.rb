module Padrino
  module Helpers
    module FormBuilder
      class UtilityFormBuilder < AbstractFormBuilder
        def error_messages_for(field)
          object.errors[field].map{|error| I18n.t 'authn.'+field.to_s+'.'+error}.join(' ')
        end
      end
    end
  end
end
