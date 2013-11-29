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
    if params[:order].present? && params[:order].to_sym == :new
      @headlines = @headlines.reorder("created_at desc")
    end
    @headlines = @headlines.paginate(:page => params[:page], :per_page => 40)
  end

  def show
    @headline = Headline.find(params[:id])
  end

  def vote
    headline = Headline.find(params[:id])
    Headline.increment_counter(:votes, headline.id)
    save_vote! headline
    redirect_to best_headlines_url
  end

  def generator
    parse_sources!
  end

  def generate
    parse_sources!
  end

private

  def parse_sources!
    @sources = []
    HEADLINE_SOURCES.each do |dict|
      @sources << dict if params[dict].to_i == 1
    end
    @sources = DEFAULT_HEADLINE_SOURCES if @sources.blank?
  end

  def save_vote!(headline)
    votes = session[:votes] || []
    votes << headline.id
    session[:votes] = votes.uniq
  end

end
