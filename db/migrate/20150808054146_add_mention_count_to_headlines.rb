class AddMentionCountToHeadlines < ActiveRecord::Migration
  def change
    add_column :headlines, :mention_count, :integer, null: false, default: 0
  end
end
