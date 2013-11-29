class Headline < ActiveRecord::Base

  scope :top, -> { order("votes desc, created_at desc") }

  serialize :sources, Array

  def self.random(sources = ["hackernews"])
    # Is this literally the worst possible way of doing this?
    # ...
    # Yes. Yes it is.
    `python #{Rails.root}/lib/markov.py #{sources.join(" ")}`.lines.map(&:chomp)
  end

  def source_objects
    Source.find_all(sources)
  end

  # def to_param
  #   "#{id}-#{name.parameterize}"
  # end

end