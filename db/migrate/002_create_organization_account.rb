class CreateOrganizationAccount < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.timestamps

      t.index :name, :unique => true
    end

    create_table :accounts do |t|
      t.belongs_to :users
      t.belongs_to :organizations
      t.timestamps
    end
  end
end
