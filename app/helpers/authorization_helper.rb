module AuthorizationHelper
  def current_ability(user=nil)
    @current_ability ||= Ability.new(user || current_user)
  end

  def is_admin?(user=nil)
    (user || current_user).roles.any?{|role| role.name==='admin'}
  end
end

UpHex::Pulse.helpers AuthorizationHelper
