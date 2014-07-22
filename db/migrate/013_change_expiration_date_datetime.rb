class ChangeExpirationDateDatetime < ActiveRecord::Migration
  def change
    change_column :providers, :expiration_date, :datetime
  end
end
