class AddIndexOnSourceHeadlinesCreatedAt < ActiveRecord::Migration
  def change
    add_index :source_headlines, :created_at
  end
end
