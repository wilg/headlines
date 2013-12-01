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
      @sorting_top = true
      @headlines = Headline.top
      if params[:timeframe].present? && params[:timeframe].to_sym == :all
      elsif params[:timeframe].present? && params[:timeframe].to_sym == :yesterday
        @headlines = @headlines.on_day(Date.yesterday)
      else
        @headlines = @headlines.on_day(Date.today)
      end
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
    Headline.transaction do
      @headline = Headline.find(params[:id])
      if params[:down].to_i == 1
        if can_downvote?(@headline) && !did_downvote?(@headline)
          downvote_headline! @headline
        else
          clear_votes! @headline
        end
      else
        if did_upvote?(@headline)
          clear_votes! @headline
        else
          upvote_headline! @headline
        end
      end
    end
    @headline.reload
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
    Source.all.each do |source|
      @sources << source.id if params[source.id].to_i == 1
    end
    @sources = Source.all.reject{|s| !s.default }.map(&:id) if @sources.blank?
  end

end
