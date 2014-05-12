class CreatePortfolioStreams < ActiveRecord::Migration
  def change
    create_join_table :portfolios, :streams,
      :table_name => :portfolio_streams do |t|
      t.timestamps

      t.index :portfolio_id
      t.index :stream_id
      t.index [:portfolio_id, :stream_id], :unique => true
    end
  end
end
