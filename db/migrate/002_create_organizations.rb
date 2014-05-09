class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.text :name, :null => false
      t.text :slug, :null => false
      t.timestamps

      t.index :name
      t.index :slug, :unique => true
    end
  end
end
