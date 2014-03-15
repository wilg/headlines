class AddApiKeyToUsers < ActiveRecord::Migration
  def up
    add_column :users, :api_key, :string
    User.all.each do |u|
      u.generate_api_key
      u.save!
    end
  end

  def down
    remove_column :users, :api_key
  end
end
