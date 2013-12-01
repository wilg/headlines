class HeadlinesController < ApplicationController

  def save

    if Headline.salted_hash(params[:headline]) != params[:hash]
      head :forbidden
      return
    end

    headline = Headline.where(name: params[:headline]).first_or_create
    headline.sources = params[:sources].split(",")
    headline.save

    upvote_headline! headline

    head :ok
  end

  def best
    # Start trending
    if params[:order].present? && params[:order].to_sym == :new
      @headlines = Headline.top.reorder("created_at desc")
    elsif params[:order].present? && params[:order].to_sym == :trending
      @headlines = Headline.hot
    else
      @headlines = Headline.top
    end
    if params[:filter].present? && params[:filter].to_sym != :all
      @headlines = @headlines.where(["sources ILIKE ?", "%#{params[:filter]}%"])
    end
    if params[:category].present? && params[:category].to_sym != :all
      @headlines = @headlines.in_category(params[:category].to_s)
    end
    if params[:q].present?
      @headlines = @headlines.where("name ilike (?)", "%#{params[:q]}%")
    end
    @headlines = @headlines.paginate(:page => params[:page], :per_page => 40)
  end

  def show
    @headline = Headline.find(params[:id])
  end

  def vote
    headline = Headline.find(params[:id])
    upvote_headline! headline
    head :ok
  end

  def generator
    parse_sources!
  end

  def generate
    parse_sources!
  end

  def game_vote
    if params[:yep].present?
      upvote_headline! Headline.find(params[:yep])
    elsif params[:nope].present?
      params[:nope].split(",").each do |bad_id|
        downvote_headline! Headline.find(bad_id)
      end
    end
  end

private

  def upvote_headline!(headline)
    Headline.increment_counter(:votes, headline.id)
    save_vote! headline
  end

  def downvote_headline!(headline)
    Headline.decrement_counter(:votes, headline.id)
    clear_vote!(headline)
  end

  def parse_sources!
    @sources = []
    Source.all.each do |source|
      @sources << source.id if params[source.id].to_i == 1
    end
    @sources = Source.all.reject{|s| !s.default }.map(&:id) if @sources.blank?
  end

  def save_vote!(headline)
    votes = session[:votes] || []
    votes << headline.id
    session[:votes] = votes.uniq
  end

  def clear_vote!(headline)
    votes = session[:votes] || []
    votes.delete(headline.id)
    session[:votes] = votes.uniq
  end

end
