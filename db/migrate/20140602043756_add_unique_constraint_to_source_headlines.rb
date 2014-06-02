class AddUniqueConstraintToSourceHeadlines < ActiveRecord::Migration
  def change
    remove_index :source_headlines, ["source_id", "name_hash"]
    add_index    :source_headlines, ["source_id", "name_hash"], unique: true
  end
end
