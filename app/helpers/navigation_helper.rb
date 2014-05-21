module NavigationHelper
  def organization_name_tag
    org_name = nil
    if current_user
      org_name = current_user.organizations.first if current_user.organizations.any?
    end
    org_name || I18n.t("navigation.title.default")
  end
end

UpHex::Pulse.helpers NavigationHelper
