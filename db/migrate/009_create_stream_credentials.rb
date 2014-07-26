class CreateStreamCredentials < ActiveRecord::Migration
  def change
    create_table :stream_credentials do |t|
      t.references :credential_token, :null => false
      t.references :stream,           :null => false
      t.timestamps

      t.index :credential_token_id
      t.index :stream_id
      t.index [:credential_token_id, :stream_id], :unique => true
    end
  end
end
