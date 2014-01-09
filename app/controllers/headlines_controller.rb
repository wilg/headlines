class HeadlinesController < ApplicationController

  before_filter :protect_api, only: [:random, :show]

  def index
    if params[:user_id]
      @user = User.find_by_login(params[:user_id])
      @headlines = headlines_sorted_by_params @user.headlines
    else
      @is_main_browse_page = true
      @headlines = headlines_sorted_by_params Headline.all, {order: :top, timeframe: :today, q: nil}
    end
    @headlines = default_pagination @headlines
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
