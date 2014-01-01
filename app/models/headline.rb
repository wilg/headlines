require 'digest/sha1'

class Headline < ActiveRecord::Base

  scope :top, -> { order("vote_count desc, created_at desc") }
  scope :hot, -> { order("(vote_count / (extract(epoch from now()) - extract(epoch from created_at))) desc").where("created_at < ?", 20.minutes.ago).where("vote_count > 1 AND vote_count < 50") }
  scope :today, -> { where("created_at > ?", 1.day.ago) }
  scope :this_week, -> { where("created_at > ?", 7.days.ago) }
  scope :yesterday, -> { where("created_at > ? AND created_at < ?", 2.days.ago, 1.day.ago) }
  scope :newest, -> { order("created_at desc") }

  scope :in_category, -> (category) {
    cat_sources = HeadlineSources::Source.categories[category].map{|s|
      "%#{s.id}%"
    }
    where{sources.like_any cat_sources}
  }

  validates_presence_of :name

  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  belongs_to :creator, class_name: "User"

  has_many :source_headline_fragments, dependent: :destroy
  has_many :source_headlines, through: :source_headline_fragments

  before_save do
    self.name_hash = Headline.name_hash(self.name)
    calculate_vote_count!
  end

  def calculate_vote_count!
    self.vote_count = self.votes.upvotes.sum(:value)
  end

  def self.name_hash(name)
    name.parameterize
  end

  validate :ensure_name_is_not_changed_significantly, on: :update

  def ensure_name_is_not_changed_significantly
    if self.name.parameterize != self.name_was.parameterize
      errors.add :name, 'was changed too much'
    end
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

  def downvote_count
    @downvote_count ||= votes.downvotes.sum(:value).abs
  end

  def upvote_count
    @upvote_count ||= votes.upvotes.sum(:value)
  end

  def sources
    source_headlines.map(&:source).uniq
  end

  def create_sources!(sources_json_array)
    sources_json_array.each_with_index do |source_hash, i|

      source_headline = SourceHeadline.where(name: source_hash['source_phrase'], source_id: source_hash['source_id']).first_or_create

      fragment = SourceHeadlineFragment.new
      fragment.headline = self
      fragment.source_headline = source_headline
      fragment.source_headline_start = source_headline.name.downcase.index(source_hash['fragment'].downcase)
      fragment.source_headline_end = fragment.source_headline_start + source_hash['fragment'].length
      fragment.index = i
      fragment.save!

    end
  end

  def shitty?
    vote_count < 1
  end

end