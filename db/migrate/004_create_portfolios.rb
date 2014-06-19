class CreatePortfolios < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'

    create_table :portfolios, :id => :uuid do |t|
      t.text :name, :null => false
      t.belongs_to :organization, :null => false
      t.timestamps

      t.index :name
      t.index :organization_id
    end
  end
end
