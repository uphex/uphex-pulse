class AddDeletedFlagToProvider < ActiveRecord::Migration
  def change
    add_column :providers, :deleted, :boolean, :default => false
  end
end