class AddScoreIndexToHeadlines < ActiveRecord::Migration
  def change
    add_index :headlines, :score
  end
end
