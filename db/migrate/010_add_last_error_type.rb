class AddLastErrorType < ActiveRecord::Migration
  def change
    add_column :metrics, :last_error_type, :string
  end
end