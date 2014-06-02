require 'active_model/model'
require 'active_support/inflector'

class UserRegistration
  include ActiveModel::Model

  attr_accessor :user_name
  attr_accessor :user_email
  attr_accessor :user_password
  attr_accessor :organization_name

  attr_accessor :user
  attr_accessor :organization

  validate :validate_child_objects

  def validate_child_objects
    self.user         = user_from_attributes
    self.organization = organization_from_attributes

    child_objects = [self.user, self.organization]
    child_objects.map(&:valid?)

    child_objects.each do |o|
      composite_object_name = o.class.name.underscore.to_sym

      o.errors.each do |field_name, *errors|
        composite_field_name = [composite_object_name, field_name].join('_').to_sym
        errors.each { |e| self.errors.add composite_field_name, e }
      end
    end
  end

  def user
    @user ||= user_from_attributes
  end

  def organization
    @organization ||= organization_from_attributes
  end

  def user_from_attributes
    User.new(
      :name     => user_name,
      :email    => user_email,
      :password => user_password
    )
  end

  def organization_from_attributes
    Organization.new(
      :name => organization_name
    )
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  def persist!
    ActiveRecord::Base.transaction do
      organization.save!
      user.save!
      user.organizations << organization
    end
  end
end
