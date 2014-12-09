class AddDeletedFlagToPortfolio < ActiveRecord::Migration
  def change
    add_column :portfolios, :deleted, :boolean, :default => false
  end
end