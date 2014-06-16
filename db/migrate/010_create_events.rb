class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.text :kind,            :null => false
      t.datetime :occurred_at, :null => false

      t.integer :targetable_id
      t.text    :targetable_type

      t.json :metadata

      t.timestamps

      t.index :kind
      t.index :occurred_at
      t.index [:targetable_type, :targetable_id]
    end
  end
end
