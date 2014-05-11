class Portfolio < ActiveRecord::Base
  belongs_to :organization

  validates :name, :presence => true
  validates :organization, :presence => true
end
