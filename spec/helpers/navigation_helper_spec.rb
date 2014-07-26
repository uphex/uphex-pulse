require 'environment_spec_helper'
require 'app/helpers/navigation_helper'
require 'spec/support/translation_matchers'

describe NavigationHelper do
  let(:model) do
    c = described_class
    Class.new { include c }.new
  end

  let(:user) {
    User.new.tap do |u|
      u.organizations.build organization.attributes
    end
  }

  let(:first_organization_name) {
    'first-org-name'
  }

  let(:organization) {
    Organization.new(:name => first_organization_name)
  }

  it "shows the first organization name if the current user belongs to at least one" do
    name = "org-name"
    current_user = User.new.tap { |u| u.organizations.build :name => name }
    allow(model).to receive(:current_user).and_return current_user
    expect(model.organization_name_tag).to include(name)
  end

  it "shows the default navigation if the current user has no organizations" do
    allow(model).to receive(:current_user).and_return User.new
    expect(model.organization_name_tag).to have_message "navigation.title.default"
  end

  it "shows the default navigation if there is no current user" do
    allow(model).to receive(:current_user).and_return nil
    expect(model.organization_name_tag).to have_message "navigation.title.default"
  end
end
