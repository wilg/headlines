class CreateHeadlines < ActiveRecord::Migration
  def change
    create_table :headlines do |t|
      t.string :name
      t.integer :votes, default: 0, null: false
      t.timestamps
    end
  end
end
