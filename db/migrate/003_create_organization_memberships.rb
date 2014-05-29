
class CreateOrganizationMemberships < ActiveRecord::Migration
  def change
    create_table :organization_memberships do |t|
      t.references :organization
      t.references :user
      t.timestamps

      t.index :organization_id
      t.index :user_id
      t.index [:organization_id, :user_id], :unique => true
    end
  end
end
