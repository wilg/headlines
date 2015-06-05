class AddTwitterRetweetsAndFavorites < ActiveRecord::Migration
  def change
    add_column :headlines, :retweet_count, :integer
    add_column :headlines, :favorite_count, :integer
  end
end
