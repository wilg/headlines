require 'digest/sha1'

class Headline < ActiveRecord::Base
  include HeadlinePhotoConcern
  include Rails.application.routes.url_helpers

  scope :top, -> { order("headlines.vote_count desc, headlines.created_at desc") }
  scope :hot, -> { order("(headlines.vote_count / (extract(epoch from now()) - extract(epoch from headlines.created_at))) desc").where("headlines.created_at < ?", 20.minutes.ago).where("headlines.vote_count > 1 AND headlines.vote_count < 50") }
  scope :today, -> { where("headlines.created_at > ?", 1.day.ago) }
  scope :this_week, -> { where("headlines.created_at > ?", 7.days.ago) }
  scope :yesterday, -> { where("headlines.created_at > ? AND headlines.created_at < ?", 2.days.ago, 1.day.ago) }
  scope :newest, -> { order("headlines.created_at desc") }

  scope :no_metadata, -> { includes(:source_headline_fragments).where(source_headline_fragments: {headline_id: nil}) }

  scope :in_category, -> (category) {
    cat_sources = HeadlineSources::Source.categories[category].map{|s|
      "%#{s.id}%"
    }
    where{sources.like_any cat_sources}
  }

  scope :with_name,  -> (name){ where(name_hash: Headline.name_hash(name)) }

  validates_presence_of :name
  validates_uniqueness_of :name_hash

  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  belongs_to :creator, class_name: "User"

  has_many :source_headline_fragments, dependent: :destroy
  has_many :source_headlines, through: :source_headline_fragments

  serialize :source_names
  serialize :photo_data, Hash

  before_save do
    self.name_hash = Headline.name_hash(self.name)
    calculate_vote_count!
  end

  # after_create do
  #   find_photo! if needs_photo_load?
  # end

  def calculate_vote_count!
    self.vote_count = self.votes.upvotes.sum(:value)
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

  def downvote_count
    @downvote_count ||= votes.downvotes.sum(:value).abs
  end

  def upvote_count
    @upvote_count ||= votes.upvotes.sum(:value)
  end

  def sources
    source_headlines.map(&:source)
  end

  def create_sources!(sources_json_array)
    SourceHeadlineFragment.transaction do
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
  end

  def shitty?
    vote_count < 1
  end

  def tweeted_from_bot?
    bot_shared_at.present?
  end

  def bot_tweet_url
    "https://twitter.com/headlinesmasher/status/#{bot_share_tweet_id}"
  end

  def tweet_from_bot!
    text = "#{name} #{Rails.application.routes.url_helpers.headline_url(self, :host => "www.headlinesmasher.com")}"
    tweet = TWITTER_BOT_CLIENT.update(text)
    self.bot_shared_at = Time.now
    self.bot_share_tweet_id = tweet.id
    self.save!
  end

end