class Headline < ActiveRecord::Base

  scope :top, -> { order("votes desc, created_at desc") }

  serialize :sources, Array

  def self.random(dicts = ["hackernews"])
    # Is this literally the worst possible way of doing this?
    # ...
    # Yes. Yes it is.
    `python #{Rails.root}/lib/markov.py #{dicts.join(" ")}`.lines.map(&:chomp)
  end

end