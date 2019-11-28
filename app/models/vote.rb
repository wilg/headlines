class Vote < ApplicationRecord

  belongs_to :user
  belongs_to :headline

  scope :upvotes, -> { where("value > 0") }
  scope :downvotes, -> { where("value < 0") }

  validates_presence_of :headline

end
