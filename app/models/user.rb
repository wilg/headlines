class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :rememberable, :trackable

  validates_uniqueness_of    :login,     :case_sensitive => false, :allow_blank => true, :if => :login_changed?
  validates_presence_of   :password, :on=>:create
  validates_confirmation_of   :password, :on=>:create
  validates_length_of :password, :within => Devise.password_length, :allow_blank => true

  has_many :votes, counter_cache: true
  has_many :headlines, foreign_key: :creator_id
  has_many :voted_headlines, through: :votes, source: :headline

  scope :top, -> { order("karma desc") }

  before_save do
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

end
