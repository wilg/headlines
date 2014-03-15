class AddApiRequestsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :api_requests, :integer, null: false, default: 0
    add_index :users, :api_key, unique: true
  end
end
