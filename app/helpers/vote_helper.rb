module VoteHelper

  def did_upvote?(headline)
    session[:votes].present? && session[:votes].include?(headline.id)
  end

  def can_downvote?(headline)
    session[:votes].present? && session[:votes].length > 15
  end

  def did_downvote?(headline)
    session[:dv].present? && session[:dv].include?(headline.id)
  end

  def upvote_headline!(headline)
    clear_votes!(headline)
    Headline.increment_counter(:votes, headline.id)
    session_save_upvote! headline
  end

  def downvote_headline!(headline)
    clear_votes!(headline)
    Headline.decrement_counter(:votes, headline.id)
    session_save_downvote! headline
  end

  def clear_votes!(headline)
    if did_upvote?(headline)
      Headline.decrement_counter(:votes, headline.id)
      session_clear_upvote!(headline)
    end
    if did_downvote?(headline)
      Headline.increment_counter(:votes, headline.id)
      session_clear_downvote!(headline)
    end
  end

  def session_save_upvote!(headline)
    votes = session[:votes] || []
    votes << headline.id
    session[:votes] = votes.uniq
  end

  def session_clear_upvote!(headline)
    votes = session[:votes] || []
    votes.delete(headline.id)
    session[:votes] = votes.uniq
  end

  def session_save_downvote!(headline)
    votes = session[:dv] || []
    votes << headline.id
    session[:dv] = votes.uniq
  end

  def session_clear_downvote!(headline)
    votes = session[:dv] || []
    votes.delete(headline.id)
    session[:dv] = votes.uniq
  end

end