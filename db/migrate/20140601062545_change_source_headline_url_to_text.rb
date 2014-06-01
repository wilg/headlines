class ChangeSourceHeadlineUrlToText < ActiveRecord::Migration
  def up
    change_column :source_headlines, :url, :text
  end
  def down
    change_column :source_headlines, :url, :string
  end
end
