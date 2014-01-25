require 'digest/sha1'

class Headline < ActiveRecord::Base

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

  after_create do
    find_photo! if needs_photo_load?
  end

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

  TRUMP_WORDS = ['obama', 'texas', 'california', 'moon', 'robot', 'police', 'cop', 'sheriff', 'dog', 'cat', 'chimp', 'baby', 'oprah', 'romney', 'wedding', 'insect', 'nintendo', 'xbox', 'bitcoin', 'halloween', 'disney', 'hitler', 'stripper', 'sex', 'baby', 'babies', 'bacon', 'god', 'jesus', 'mario']

  IGNORED_WORDS = ['announcement', 'this', 'please', 'his', 'hers', 'him', 'her', 'a', 'the', 'them', 'of', 'your', 'on', 'an', 'i', 'but', 'here', 'cant', 'can', 'continues', 'continue', 'another', 'remarkable', 'example', 'in', 'into', 'now', 'is', 'story', 'many', 'actually', 'really', 'you', 'seriously', 'new', 'by', 'before', 'does', 'turning', 'that', 'will', 'all', 'us', 'something','resembles','basically','about','might','have', 'we', 'may', 'be', 'fact']

  def to_tag
    short_name = name.parameterize.gsub("-s-", "s-").gsub("-t-", "t-").split("-").reject{|w| IGNORED_WORDS.include?(w) }.uniq
    def length_with_bonus(str)
      bonus = 0
      bonus = 5 if TRUMP_WORDS.include?(str) || TRUMP_WORDS.include?(str.pluralize)
      str.length + bonus
    end
    return short_name.compact.sort{|a, b| length_with_bonus(b) <=> length_with_bonus(a)}.first(6).join(",")
  end

  def has_photo?
    photo_data.present? && photo_data['flickr'].present?
  end

  def needs_photo_load?
    photo_data.present? && photo_data['flickr'] != false
  end

  def find_photo!(search = to_tag)
    photo = flickr.photos.search(tags: search, per_page: 20, sort: 'relevance', media: 'photos', extras: "owner_name,license").to_a.sample
    if photo
      photo_data['flickr'] = photo.to_hash
    else
      photo_data['flickr'] = false
    end
    save!
  end

  def clear_photo!
    photo_data = {}
    save!
  end

  def image_url!(*args)
    find_photo! unless needs_photo_load?
    image_url(*args)
  end

  def image_url(size = 'q')
    size = size.nil? ? "" : "_#{size}"
    if has_photo?
      r = photo_data['flickr']
      FlickRaw::PHOTO_SOURCE_URL % [r['farm'], r['server'], r['id'], r['secret'], size, "jpg"]
    else
      return "http://lorempixel.com/150/150" if size == 'q'
      "http://lorempixel.com/400/200"
    end
  end

  def image_owner
    photo_data['flickr']['ownername'] if has_photo? && photo_data['flickr']['ownername'].present?
  end

  def image_info_url
    FlickRaw.url_photopage FlickRaw::Response.build(photo_data['flickr'], 'photo')
  end

end