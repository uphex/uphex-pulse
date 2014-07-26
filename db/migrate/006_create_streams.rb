class CreateStreams < ActiveRecord::Migration
  def change
    create_table :streams do |t|
      t.text :name,             :null => false
      t.text :provider_name,    :null => false
      t.belongs_to :organization, :null => false

      t.json :metadata

      t.datetime :expires_at
      t.timestamps

      t.index :name
      t.index :organization_id
      t.index :provider_name
      t.index :expires_at
      t.index [:organization_id, :provider_name]
      t.index [:organization_id, :name]
    end
  end
end
