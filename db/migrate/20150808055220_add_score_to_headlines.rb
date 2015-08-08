class AddScoreToHeadlines < ActiveRecord::Migration
  def change
    add_column :headlines, :score, :float
  end
end
