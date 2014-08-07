
class CreateOrganizationMemberships < ActiveRecord::Migration
  def change
    create_table :organization_memberships do |t|
      t.references :organization, :null => false
      t.references :user,         :null => false
      t.timestamps

      t.index :organization_id
      t.index :user_id
      t.index [:organization_id, :user_id], :unique => true
    end
  end
end
