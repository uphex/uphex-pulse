class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |table|
      table.column :name,     :string
      table.timestamps
      table.column :analyzed_at, :datetime
      table.belongs_to :providers
    end
  end
end