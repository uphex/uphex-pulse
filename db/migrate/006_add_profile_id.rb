class AddProfileId < ActiveRecord::Migration
  def change
    add_column :providers, :profile_id, :string
  end
end