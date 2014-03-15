class AddTweetBotIdToHeadlines < ActiveRecord::Migration
  def change
    add_column :headlines, :bot_shared_at, :datetime
    add_column :headlines, :bot_share_tweet_id, :string
  end
end
