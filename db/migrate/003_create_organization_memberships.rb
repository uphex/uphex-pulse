
class CreateOrganizationMemberships < ActiveRecord::Migration
  def change
    create_join_table :organizations, :users,
      :table_name => :organization_memberships do |t|
      t.timestamps

      t.index :organization_id
      t.index :user_id
      t.index [:organization_id, :user_id], :unique => true
    end
  end
end
