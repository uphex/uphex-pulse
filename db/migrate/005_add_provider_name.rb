class AddProviderName < ActiveRecord::Migration
  def change
    add_column :providers, :provider_name, :string
  end
end