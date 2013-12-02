class AddDepthToHeadlines < ActiveRecord::Migration
  def change
    add_column :headlines, :depth, :integer, default: 2
  end
end
