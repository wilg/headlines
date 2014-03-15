class SourceHeadlinesController < ApplicationController

  def show
    @source_headline = SourceHeadline.find(params[:id])
    @headlines = default_pagination headlines_sorted_by_params @source_headline.headlines
  end

end
