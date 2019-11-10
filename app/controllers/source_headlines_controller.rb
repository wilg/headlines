class SourceHeadlinesController < ApplicationController

  def show
    @source_headline = SourceHeadline.find(params[:id])
    @headlines = default_pagination headlines_sorted_by_params @source_headline.headlines
  end

  def download
    if current_user && current_user.admin?
      limit = params[:limit].to_i.zero? ? 1000 : params[:limit].to_i
      collection = if params[:percent]
        SourceHeadline.random_set(percent: params[:percent].to_f).pluck(:name)
      else
        SourceHeadline.random_set(approximate_limit: limit).pluck(:name)
      end
      respond_to do |format|
        format.json { render json: collection }
        format.text { render text: collection.join("\n") }
      end
    else
      head :not_found
    end
  end

end
