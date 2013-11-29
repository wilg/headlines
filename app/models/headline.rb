class Headline < ActiveRecord::Base

  scope :top, -> { order("votes desc") }

  def self.random
    # Is this literally the worst possible way of doing this?
    # ...
    # Yes.
    `python #{Rails.root}/lib/markov.py`.lines.map(&:chomp)
  end

end