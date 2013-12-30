class SourceHeadlineFragment < ActiveRecord::Base

  belongs_to :source_headline
  belongs_to :headline

  def fragment
    source_headline.name[source_headline_start...source_headline_end]
  end

  def source
    source_headline.source
  end

end
