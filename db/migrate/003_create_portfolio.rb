class CreatePortfolio < ActiveRecord::Migration
  def change
    create_table :portfolios do |t|
      t.string :name
      t.timestamps
      t.belongs_to :organizations

      t.index :name, :unique => true
    end
  end
end
