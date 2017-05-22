class AddRetweetedAtToHeadlines < ActiveRecord::Migration
  def change
    add_column :headlines, :retweeted_at, :datetime
  end
end
