class ChangeSourceHeadlineNameToText < ActiveRecord::Migration
  def change
    change_column :source_headlines, :name, :text
  end
end
