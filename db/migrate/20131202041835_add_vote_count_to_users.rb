class AddVoteCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :vote_count, :integer, default: 0, null: false
  end
end
