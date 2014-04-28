module AuthorizationHelper
  def current_ability(user=nil)
    @current_ability ||= Ability.new(user || current_user)
  end
end

UpHex::Pulse.helpers AuthorizationHelper
