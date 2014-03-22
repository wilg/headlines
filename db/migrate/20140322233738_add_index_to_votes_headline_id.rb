class AddIndexToVotesHeadlineId < ActiveRecord::Migration
  def change
    add_index :votes, :headline_id
    add_index :votes, :user_id
    add_index :comments, :headline_id
    add_index :comments, :user_id
    add_index :headlines, :creator_id
  end
end
