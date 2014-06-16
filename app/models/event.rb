require 'active_record'

class Event < ActiveRecord::Base
  belongs_to :targetable, :polymorphic => true

  validates :kind,
    :presence => true

  validates :occurred_at,
    :presence => true
end
