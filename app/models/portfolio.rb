class Portfolio < ActiveRecord::Base
  belongs_to :organization
  has_many :streams

  validates :name, :presence => true
  validates :organization, :presence => true
end
