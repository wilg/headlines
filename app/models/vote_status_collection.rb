class VoteStatusCollection

  def initialize(user = nil, headline_collection = nil)
    @user = user
    @votes = @user.votes.where(headline_id: headline_collection.map(&:id)).all if @user
  end

  def did_upvote?(headline)
    return false unless @user
    vote = @votes.select{|v| v.headline_id == headline.id }.first
    vote.present? && vote.value > 0
  end

  def did_downvote?(headline)
    return false unless @user
    vote = @votes.select{|v| v.headline_id == headline.id }.first
    vote.present? && vote.value < 0
  end

end
