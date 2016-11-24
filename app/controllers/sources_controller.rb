class SourcesController < ApplicationController

  def show
    @source = HeadlineSource.find(params[:id])
    @headlines = default_pagination headlines_sorted_by_params @source.headlines.top
  end

  def index
    @source_groups = HeadlineSource.all.sort_by{|s| "#{s.fake?}#{s.name.downcase}" }.group_by{|s| s.fake? ? "Fake News Sites" : "Headline Sources" }
  end

end
