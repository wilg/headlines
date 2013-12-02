class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer :value
      t.integer :headline_id
      t.integer :user_id
      t.string  :ip
      t.timestamps
    end

    add_column :headlines, :creator_id, :integer

    Headline.all.each do |h|
      h.votes.create!(value: h[:votes])
    end

  end
end
