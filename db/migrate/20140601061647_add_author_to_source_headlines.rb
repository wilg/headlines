class AddAuthorToSourceHeadlines < ActiveRecord::Migration
  def change
    add_column :source_headlines, :author, :string
    add_column :source_headlines, :section, :string
  end
end
