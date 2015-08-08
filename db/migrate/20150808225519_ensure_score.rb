class EnsureScore < ActiveRecord::Migration
  def up
    Headline.update_all('score = vote_count')
    Headline.scorable.each(&:save)
  end
end
