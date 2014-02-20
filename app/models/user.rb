class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :rememberable, :trackable

  validates_uniqueness_of    :login,     :case_sensitive => false, :allow_blank => true, :if => :login_changed?
  validates_presence_of   :password, :on=>:create
  validates_confirmation_of   :password, :on=>:create
  validates_length_of :password, :within => Devise.password_length, :allow_blank => true

  has_many :votes, dependent: :destroy
  has_many :headlines, foreign_key: :creator_id, dependent: :nullify, counter_cache: :saved_headlines_count
  has_many :voted_headlines, through: :votes, source: :headline

  has_many :comments, dependent: :destroy

  scope :top, -> { order("karma desc") }

  before_save do
    calculate_karma!
  end

  before_create :generate_api_key

  def generate_api_key
    begin
      self.api_key = SecureRandom.hex
    end while self.class.exists?(api_key: api_key)
  end

  def calculate_karma!
    self.karma = self.headlines.sum(:vote_count) - self.headlines.count
    self.vote_count = voted_headlines_without_self.count
  end

  def upvote_headline!(headline)
    clear_votes!(headline)
    headline.votes.create(user: self, value: 1)
    headline.save!
    headline.creator.save! if headline.creator
    self.save!
  end

  def downvote_headline!(headline)
    clear_votes!(headline)
    headline.votes.create(user: self, value: -1)
    headline.save!
    headline.creator.save! if headline.creator
    self.save!
  end

  def clear_votes!(headline)
    clear_votes headline
    headline.save!
    headline.creator.save! if headline.creator
    self.save!
  end

  def clear_votes(headline)
    votes.where(headline: headline).delete_all
  end

  def to_param
    login
  end

  def voted_headlines_without_self
    voted_headlines.where("headlines.creator_id is null or headlines.creator_id != ?", id)
  end

  def vote_statuses(headlines)
    VoteStatusCollection.new(self, headlines)
  end

end
