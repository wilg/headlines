class AddKarmaToUsers < ActiveRecord::Migration
  def change
    add_column :users, :karma, :integer, default: 0, null: false
    User.all.each(&:save)
  end
end
