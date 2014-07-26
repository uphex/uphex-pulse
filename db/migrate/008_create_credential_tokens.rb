class CreateCredentialTokens < ActiveRecord::Migration
  def change
    create_table :credential_tokens do |t|
      t.text :token,        :null => false
      t.json :metadata,     :null => false, :default => {}

      t.index :token
    end
  end
end
