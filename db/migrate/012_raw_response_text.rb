class RawResponseText < ActiveRecord::Migration
  def change
    change_column :providers, :raw_response, :text, :limit => nil
  end
end
