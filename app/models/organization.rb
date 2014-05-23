require 'active_record'

class Organization < ActiveRecord::Base
  has_many :portfolios

  validates :name, :presence => true
  validates :slug,
    :presence => true,
    :uniqueness => { :allow_nil => true }

  def name=(value)
    self.slug = value.to_s.
      gsub(/[^[[:alnum:]]]/, '_').
      downcase.dasherize.
      gsub(/-+/, '-').
      gsub(/(^-|-$)/, '')

    super value
  end
end
