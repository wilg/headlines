class SourcesController < ApplicationController

  def show
    @source = HeadlineSource.find(params[:id])
    @headlines = @source.headlines.top.paginate(:page => params[:page], :per_page => 40)
  end

end
