require 'digest/sha1'

class Headline < ActiveRecord::Base
  include HeadlinePhotoConcern
  include AppropriatenessConcern
  include Rails.application.routes.url_helpers

  scope :top, -> { order("headlines.score desc, headlines.created_at desc") }
  scope :bottom, -> { order("headlines.score asc, headlines.created_at desc") }
  scope :hot, -> { order("(headlines.vote_count / (extract(epoch from now()) - extract(epoch from headlines.created_at))) desc").where("headlines.created_at < ?", 20.minutes.ago).where("headlines.vote_count > 1 AND headlines.vote_count < 50") }
  scope :trending, -> { order("(COALESCE(headlines.retweet_count, 0) + headlines.mention_count + COALESCE(headlines.favorite_count, 0)) desc, headlines.updated_at desc") }
  scope :created_in_the_past, -> (timeframe){ where("headlines.created_at > ?", timeframe.ago) }
  scope :today, -> { created_in_the_past 1.day }
  scope :this_week, -> { created_in_the_past 7.days }
  scope :this_month, -> { created_in_the_past 30.days }
  scope :yesterday, -> { where("headlines.created_at > ? AND headlines.created_at < ?", 2.days.ago, 1.day.ago) }
  scope :newest, -> { order("headlines.created_at desc") }
  scope :babies, -> { where(vote_count: 1) }
  scope :just_in, -> { this_month.babies.order("random()") }

  scope :no_metadata, -> { includes(:source_headline_fragments).where(source_headline_fragments: {headline_id: nil}) }

  scope :tweeted, -> { where("bot_shared_at is not null") }
  scope :scorable, -> { where("comments_count > 0 OR retweet_count > 0 OR favorite_count > 0 OR mention_count > 0") }
  scope :tweetable, -> { where({bot_shared_at: nil}).appropriate }
  scope :retweetable, -> { appropriate.where.not({bot_shared_at: nil}) }

  scope :with_name,  -> (name){ where(name_hash: Headline.name_hash(name)) }
  scope :minimum_score, -> (score){ where("score > ?", score) }

  validates_presence_of :name
  validates_uniqueness_of :name_hash

  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  belongs_to :creator, class_name: "User"

  has_many :source_headline_fragments, dependent: :destroy
  has_many :source_headlines, through: :source_headline_fragments

  has_many :headline_twitter_mentions

  serialize :source_names, Array
  serialize :photo_data, Hash

  before_validation do
    self.name_hash = Headline.name_hash(self.name)
    calculate_vote_count!
    calculate_score!
  end

  # after_create do
  #   find_photo! if needs_photo_load?
  # end

  def calculate_vote_count!
    self.vote_count = self.votes.upvotes.sum(:value)
  end

  def calculate_score!
    new_score = vote_count.to_f
    # Unique commenters who are not the creator
    new_score += comments.map{|c| c.user.id}.reject{|i| i == self.creator_id }.uniq.length.to_f
    new_score += retweet_count.to_f * 3
    new_score += favorite_count.to_f * 2
    new_score += if tweeted_from_bot?
      mention_count.to_f * 2
    else
      mention_count.to_f * 4
    end
    self.score = new_score
  end

  def display_score
    score.floor
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

  def set_source_names
    names = source_headlines.map(&:source_id)
    self.source_names = names if names.present?
  end

  def sources
    source_headlines.map(&:source).compact.uniq{|source| source.id}
  end

  def create_sources!(sources_json_array)
    SourceHeadlineFragment.transaction do
      sources_json_array.each_with_index do |source_hash, i|

        source_headline = SourceHeadline.find(source_hash['source_headline_id'])

        fragment = SourceHeadlineFragment.new
        fragment.headline = self
        fragment.source_headline = source_headline
        fragment.source_headline_start = source_headline.name.downcase.index(source_hash['fragment'].downcase)
        fragment.source_headline_end = fragment.source_headline_start + source_hash['fragment'].length
        fragment.index = i
        fragment.save!

      end
    end
    set_source_names
  end

  def shitty?
    vote_count < 1
  end

  def self.last_tweet_time
    Headline.where("bot_shared_at is not null").order("bot_shared_at desc").first.try(:bot_shared_at)
  end

  def self.last_retweet_time
    Headline.where("retweeted_at is not null").order("retweeted_at desc").first.try(:retweeted_at)
  end

  def tweeted_from_bot?
    bot_shared_at.present?
  end

  def bot_tweet_url
    "https://twitter.com/headlinesmasher/status/#{bot_share_tweet_id}"
  end

  def self.normalize_smart_quotes(string)
    string.gsub("’", "'").gsub("‘", "'").gsub('“', '"').gsub('”', '"')
  end

  # Must be the same length as original headline
  def repunctuated_name

    out = Headline.normalize_smart_quotes(name)

    # Weird characters
    out.gsub!("Â", " ")

    if out.count('"') == 1 && !out.match(/\d{1,2}'\d{1,2}"/)
      out = out.sub('"', ' ')
    end

    # Replace single quoted things with double quotes
    matches = out.match(/((?:\A| )'[\w\s]+'(?:\z| ))/)
    if matches
      matches.length.times do |i|
        start_i, end_i = matches.offset(i)
        pre = out[0, start_i]
        mid = out[start_i, end_i - start_i]
        post = out[end_i, out.length]
        out = pre + mid.gsub("'", "\"") + post
      end
    end

    # Replace mismatched single quotes that aren't contractions
    out.gsub!(/'([^a-zA-Z0-9_+])/, ' \1')
    out.gsub!(/([^a-zA-Z0-9_+])'/, '\1 ')
    out.gsub!(/([a-zA-Z0-9_+])'\z/, '\1 ')
    out.gsub!(/\A'([a-zA-Z0-9_+])/, ' \1')

    %w[: ? ! ;].each do |punctuation|
      out.gsub!(" #{punctuation} ", "#{punctuation}  ")
    end

    # Don't quote entire headlines
    if out.count('"') == 2 && out.start_with?('"') && out.end_with?('"')
      out.gsub!('"', ' ')
    end

    terminators = %w[. , : ;]
    terminators << ")" if out.count("(") == 0 && out.count(")") == 1
    terminators.each do |terminator|
      if out.end_with?(terminator) && !out.end_with?("...")
        out = out.chop + " "
      end
      if out.count(terminator) == 1 && out.strip.end_with?(terminator)
        out = out.sub(terminator, ' ')
      end
    end

    # Mismatched double quotes
    open_quotes = out.scan(/[ -]"/).length
    close_quotes = out.scan(/[ -]"/).length
    if open_quotes > close_quotes
      out = out.reverse.sub("\" ", "  ").reverse
    end
    if open_quotes < close_quotes
      out = out.sub("\" ", "  ")
    end

    out
  end

  def formatted_name
    @_formatted_name ||= repunctuated_name.squish
  end

  def tweet_from_bot!
    tweet = TWITTER_BOT_CLIENT.update(formatted_name)
    self.bot_shared_at = Time.now
    self.bot_share_tweet_id = tweet.id
    self.save!
  end

  def retweet_from_bot!
    rt = TWITTER_BOT_CLIENT.retweet(bot_share_tweet_id)
    self.retweeted_at = Time.now
    self.save!
  end

end
