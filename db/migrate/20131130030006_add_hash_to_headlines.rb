class AddHashToHeadlines < ActiveRecord::Migration

  def change
    add_column :headlines, :name_hash, :string
    Headline.all.each do |h|
      if h.name.blank?
        h.destroy
      else
        h.save!
      end
    end
  end

end
