class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :name,          :null => false
      t.text :email,         :null => false
      t.text :password_hash, :null => false
      t.timestamps

      t.index :email, :unique => true
      t.index :name
    end
  end
end
