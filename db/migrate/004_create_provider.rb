class CreateProvider < ActiveRecord::Migration
  def change
    create_table :providers do |table|
      table.column :name,     :string
      table.column :userid, :numeric
      table.column :access_token, :string
      table.column :access_token_secret, :string
      table.column :expiration_date, :date
      table.column :token_type, :string
      table.column :refresh_token, :string
      table.column :raw_response, :string

      table.belongs_to :portfolios
    end
  end
end



