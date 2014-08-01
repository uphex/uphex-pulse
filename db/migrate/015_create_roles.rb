class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      t.index :name, :unique => true
    end

    Role.create(:name=>'admin')
    Role.create(:name=>'user')

    create_table :user_roles do |t|
      t.belongs_to :users
      t.belongs_to :roles
    end
  end
end
