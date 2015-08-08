class CreateHeadlineTwitterMentions < ActiveRecord::Migration
  def change
    create_table :headline_twitter_mentions do |t|
      t.string :tweet_id, index: true
      t.string :twitter_username
      t.integer :headline_id, index: true
      t.timestamps null: false
    end
  end
end
