class SourceHeadlinesController < ApplicationController

  def show
    @source_headline = SourceHeadline.find(params[:id])
    @headlines = @source_headline.headlines.paginate(:page => params[:page], :per_page => 40)
  end

end
