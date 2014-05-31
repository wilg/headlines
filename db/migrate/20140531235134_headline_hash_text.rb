class HeadlineHashText < ActiveRecord::Migration
  def up
    change_column :headlines, :name_hash, :text
    change_column :source_headlines, :name_hash, :text
  end
  def down
    change_column :headlines, :name_hash, :string
    change_column :source_headlines, :name_hash, :string
  end
end
