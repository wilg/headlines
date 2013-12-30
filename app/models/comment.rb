class Comment < ActiveRecord::Base

  include Rakismet::Model

  belongs_to :user, counter_cache: true
  belongs_to :headline, counter_cache: true

  validates_presence_of :user
  validates_presence_of :headline
  validates_presence_of :body

  before_save do
    if Rakismet.key && self.spam?
      errors.add :body, "looks like spam"
    end
  end

  def author
    user.login
  end

end
