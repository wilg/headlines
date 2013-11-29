class HeadlinesController < ApplicationController

  def save
    headline = Headline.where(name: params[:headline]).first_or_create
    headline.sources = params[:sources].split(",")
    headline.save

    Headline.increment_counter(:votes, headline.id)
    save_vote! headline
    redirect_to best_headlines_url
  end

  def best
    @headlines = Headline.top
    if params[:filter].present? && params[:filter].to_sym != :all
      @headlines = @headlines.where(["sources ILIKE ?", "%#{params[:filter]}%"])
    end
  end

  def vote
    headline = Headline.find(params[:id])
    Headline.increment_counter(:votes, headline.id)
    save_vote! headline
    redirect_to best_headlines_url
  end

  def index
    @sources = []
    HEADLINE_DICTIONARIES.each do |dict|
      @sources << dict if params[dict].to_i == 1
    end
    @sources << HEADLINE_DICTIONARIES.first if @sources.blank?
  end

private

  def save_vote!(headline)
    votes = session[:votes] || []
    votes << headline.id
    session[:votes] = votes.uniq
  end

end
