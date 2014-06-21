module NavigationHelper
  def organization_name_tag
    org_name = nil
    if current_user
      org_name = current_user.organizations.first.name if current_user.organizations.any?
    end
    org_name || I18n.t("navigation.title.default")
  end

  def backlink_to(href, location = nil)
    opts = {}
    opts[:title] = I18n.t('navigation.backlink', :location => location) if location

    link_to(href, opts) do
      content_tag(:span, :class => 'icon-arrow-left2') {}
    end
  end
end

UpHex::Pulse.helpers NavigationHelper
