class DropVotesColumnFromHeadlines < ActiveRecord::Migration
  def change
    rename_column :headlines, :votes, :vote_count
    Headline.all.each(&:save)
  end
end
