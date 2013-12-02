require 'digest/sha1'

class Headline < ActiveRecord::Base

  scope :top, -> { order("vote_count desc, created_at desc") }
  scope :hot, -> { order("(vote_count / (extract(epoch from now()) - extract(epoch from created_at))) desc").where("created_at < ?", 20.minutes.ago).where("vote_count > 1 AND vote_count < 50") }
  scope :today, -> { where("created_at > ?", 1.day.ago) }
  scope :yesterday, -> { where("created_at > ? AND created_at < ?", 2.days.ago, 1.day.ago) }

  scope :in_category, -> (category) {
    cat_sources = Source.categories[category].map{|s|
      "%#{s.id}%"
    }
    where{sources.like_any cat_sources}
  }

  serialize :sources, Array

  validates_presence_of :name

  has_many :votes
  belongs_to :creator, class_name: "User"

  def source_objects
    Source.find_all(sources)
  end

  before_save do
    self.name_hash = Headline.name_hash(self.name)
    self.vote_count = self.votes.sum(:value)
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

  def self.salted_hash(headline)
    Digest::SHA1.hexdigest("#{headline}-#{ENV['HEADLINE_INJECTION_SALT']}")
  end

  def salted_hash
    Headline.salted_hash(name)
  end

end