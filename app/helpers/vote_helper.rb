module VoteHelper

  def did_upvote?(headline)
    user_signed_in? && current_user.votes.upvotes.where(headline: headline).exists?
  end

  def can_downvote?(headline)
    false # user_signed_in?
  end

  def did_downvote?(headline)
    user_signed_in? && current_user.votes.downvotes.where(headline: headline).exists?
  end

end