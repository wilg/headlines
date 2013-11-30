class AddHashToHeadlines < ActiveRecord::Migration

  def change
    add_column :headlines, :name_hash, :string
    Headline.all.each do |h|
      h.save!
    end
  end

end
