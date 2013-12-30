class CreateSourceHeadlines < ActiveRecord::Migration
  def change
    create_table :source_headlines do |t|
      t.string :source_id
      t.string :name
      t.string :url
      t.timestamps
    end
    add_index :source_headlines, :source_id
  end
end
