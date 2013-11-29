class HeadlinesController < ApplicationController

  def save
    headline = Headline.where(name: params[:headline]).first_or_create
    Headline.increment_counter(:votes, headline.id)
    save_vote! headline
    redirect_to best_headlines_url
  end

  def best

  end

  def vote
    headline = Headline.find(params[:id])
    Headline.increment_counter(:votes, headline.id)
    save_vote! headline
    redirect_to best_headlines_url
  end

private

  def save_vote!(headline)
    votes = session[:votes] || []
    votes << headline.id
    session[:votes] = votes.uniq
  end

end
