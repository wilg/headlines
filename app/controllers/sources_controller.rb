class SourcesController < ApplicationController

  def show
    @source = HeadlineSource.find(params[:id])
    @headlines = default_pagination headlines_sorted_by_params @source.headlines.top
  end

end
