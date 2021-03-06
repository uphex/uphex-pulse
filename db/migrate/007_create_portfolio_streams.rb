class CreatePortfolioStreams < ActiveRecord::Migration
  def change
    create_table :portfolio_streams do |t|
      t.references :portfolio, :null => false
      t.references :stream,    :null => false
      t.timestamps

      t.index :portfolio_id
      t.index :stream_id
      t.index [:portfolio_id, :stream_id], :unique => true
    end
  end
end
