class AddLastErrorTime < ActiveRecord::Migration
  def change
    add_column :metrics, :last_error_time, :datetime
  end
end