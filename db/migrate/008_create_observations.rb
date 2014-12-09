class CreateObservations < ActiveRecord::Migration
  def change
    create_table :observations do |table|
      table.column :index,     :datetime
      table.column :value,     :numeric
      table.column :metadata,     :string
      table.belongs_to :metrics
    end
  end
end