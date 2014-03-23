class AddIndexVoteCountToHeadlines < ActiveRecord::Migration
  def change

    # Deduplicate headlines
    duplicated_hashes = Headline.select(:name_hash).group(:name_hash).having("count(*) > 1").count
    duplicated_hashes.each do |duped_hash, count|
      puts "deduplicating #{duped_hash} (#{count})"
      dupes = Headline.where(name_hash: duped_hash).bottom.limit(count - 1)
      dupes.destroy_all
    end

    add_index :headlines, :vote_count
    add_index :headlines, :created_at
    add_index :headlines, :name_hash, unique: true

  end
end
