class RecountVotes < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.save
    end
  end
end
