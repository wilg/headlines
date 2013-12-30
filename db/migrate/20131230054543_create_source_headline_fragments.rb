class CreateSourceHeadlineFragments < ActiveRecord::Migration
  def change
    create_table :source_headline_fragments do |t|
      t.integer :source_headline_id
      t.integer :headline_id
      t.integer :source_headline_start
      t.integer :source_headline_end
      t.integer :index
      t.timestamps
    end
    add_index :source_headline_fragments, :source_headline_id
    add_index :source_headline_fragments, :headline_id
  end
end
