class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :rememberable, :trackable

  validates_uniqueness_of    :login,     :case_sensitive => false, :allow_blank => true, :if => :login_changed?
  validates_presence_of   :password, :on=>:create
  validates_confirmation_of   :password, :on=>:create
  validates_length_of :password, :within => Devise.password_length, :allow_blank => true

  has_many :votes, counter_cache: true, dependent: :destroy
  has_many :headlines, foreign_key: :creator_id, dependent: :nullify
  has_many :voted_headlines, through: :votes, source: :headline

  scope :top, -> { order("karma desc") }

  before_save do
    calculate_karma!
  end

  def calculate_karma!
    self.karma = self.headlines.sum(:vote_count) - self.headlines.count
  end

  def upvote_headline!(headline)
    clear_votes!(headline)
    headline.votes.create(user: self, value: 1)
    headline.save!
    headline.creator.save! if headline.creator
  end

  def downvote_headline!(headline)
    clear_votes!(headline)
    headline.votes.create(user: self, value: -1)
    headline.save!
    headline.creator.save! if headline.creator
  end

  def clear_votes!(headline)
    clear_votes headline
    headline.save!
    headline.creator.save! if headline.creator
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

  def votes_count
    voted_headlines_without_self.size
  end

  def vote_statuses(headlines)
    VoteStatusCollection.new(self, headlines)
  end

end
