class CreatePortfolios < ActiveRecord::Migration
  def change
    create_table :portfolios do |t|
      t.text :name
      t.belongs_to :organization
      t.timestamps

      t.index :name
      t.index :organization_id
    end
  end
end
