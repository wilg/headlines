class AddSavedHeadlinesCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :saved_headlines_count, :integer, default: 0, null: false
    User.all.each do |user|
      user.update_columns(saved_headlines_count: user.headlines.count)
    end
  end
end
