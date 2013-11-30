class GrubercaseEverything < ActiveRecord::Migration
  def change
    Headline.all.each do |headline|
      headline.name = headline.name.grubercase
      headline.save!
    end
  end
end
