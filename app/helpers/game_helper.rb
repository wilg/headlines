module GameHelper

  def session_vote_ids
    session[:votes].presence || [-1]
  end

  def game_headlines
    Headline.where("id not in (?)", session_vote_ids).order("random()")
  end

end
