class Headline < ActiveRecord::Base

  scope :top, -> { order("votes desc, created_at desc") }
  scope :hot, -> { order("(votes / (extract(epoch from now()) - extract(epoch from created_at))) desc").where("created_at < ?", 1.hour.ago) }

  scope :in_category, -> (category) {
    cat_sources = Source.categories[category].map{|s|
      "%#{s.id}%"
    }
    where{sources.like_any cat_sources}
  }

  serialize :sources, Array

  validates_presence_of :name

  def self.random(sources = ["hackernews"])
    # Is this literally the worst possible way of doing this?
    # ...
    # Yes. Yes it is.
    `python #{Rails.root}/lib/markov.py #{sources.join(" ")}`.lines.map(&:chomp).map(&:grubercase)
  end

  def source_objects
    Source.find_all(sources)
  end

  before_save do
    self.name_hash = Headline.name_hash(self.name)
  end

  def self.name_hash(name)
    name.parameterize
  end

  # def to_param
  #   "#{id}-#{name.parameterize}"
  # end

  def categories
    # What am I doing it's so late.
    cats = {}
    source_objects.each do |source|
      if cats[source.category].present?
        cats[source.category] = cats[source.category] + 1
      else
        cats[source.category] = 1
      end
    end
    sorted = cats.to_a.sort{|c| c[1] }
    sorted = sorted[0,2] if sorted.length > 2
    sorted.map{|pair| pair[0]}
  end

end