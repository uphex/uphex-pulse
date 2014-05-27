class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |table|
      table.column :date,     :date
      table.column :prediction_low,     :numeric
      table.column :prediction_high,     :numeric
      table.belongs_to :metrics
    end
  end
end