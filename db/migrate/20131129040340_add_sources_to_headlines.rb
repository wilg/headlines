class AddSourcesToHeadlines < ActiveRecord::Migration
  def change
    add_column :headlines, :sources, :text
  end
end
