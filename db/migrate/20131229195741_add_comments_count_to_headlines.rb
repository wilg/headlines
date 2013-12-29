class AddCommentsCountToHeadlines < ActiveRecord::Migration
  def change
    add_column :headlines, :comments_count, :integer, default: 0, null: false
    add_column :users, :comments_count, :integer, default: 0, null: false
  end
end
