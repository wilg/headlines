class HeadlinesController < ApplicationController

  before_filter :protect_api, only: [:random, :show]

  def best
    if params[:order].present? && params[:order].to_sym == :new
      @headlines = Headline.newest
    elsif params[:order].present? && params[:order].to_sym == :trending
      @headlines = Headline.hot
    else
      @sorting_top = true
      @headlines = Headline.top
      if params[:timeframe].present? && params[:timeframe].to_sym == :all
      elsif params[:timeframe].present? && params[:timeframe].to_sym == :yesterday
        @headlines = @headlines.yesterday
      elsif params[:timeframe].present? && params[:timeframe].to_sym == :this_week
        @headlines = @headlines.this_week
      else
        @headlines = @headlines.today
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

  def index
    @user = User.find_by_login(params[:user_id])
    @headlines = @user.headlines.paginate(:page => params[:page], :per_page => 40)
    if params[:order].present? && params[:order].to_sym == :top
      @headlines = @headlines.top
    else
      @headlines = @headlines.newest
    end
  end

  def show
    @headline = Headline.find(params[:id])
    respond_to do |format|
      format.html
      format.json {render partial: "headlines/headline", locals: {headline: @headline}}
    end
  end

  def random
    @headline = Headline.where("vote_count > ?", params[:minimum] || 2).order('random()').first
    respond_to do |format|
      format.html { redirect_to @headline }
      format.json {render partial: "headlines/headline", locals: {headline: @headline}}
    end
  end

  def reconstruct
    @headline = Headline.find(params[:id])
    redirect_to generator_url(reconstruct_phrase: @headline.name, reconstruct_sources: @headline.source_names.join(","))
  end

  def vote
    head :ok and return if VOTING_DISABLED
    @headline = Headline.find(params[:id])
    # Headline.transaction do
      if params[:down].to_i == 1
        if did_downvote?(@headline)
          current_user.clear_votes! @headline
        else
          current_user.downvote_headline! @headline
        end
      else
        if did_upvote?(@headline)
          current_user.clear_votes! @headline
        else
          current_user.upvote_headline! @headline
        end
      end
    # end
    @headline.reload
  end

  def destroy
    @headline = Headline.find(params[:id])
    @headline.destroy! if @headline.vote_count < 2 && @headline.creator == current_user
    respond_to do |format|
      format.html {redirect_to root_url}
      format.js
    end
  end

end
