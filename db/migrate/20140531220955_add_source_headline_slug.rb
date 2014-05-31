class AddSourceHeadlineSlug < ActiveRecord::Migration
  def change
    add_column :source_headlines, :name_hash, :string
    add_index  :source_headlines, ["source_id", "name_hash"]

    add_column :source_headlines, :published_at, :datetime
    add_column :source_headlines, :fetcher, :string
  end
end
