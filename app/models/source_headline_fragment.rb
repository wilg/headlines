class SourceHeadlineFragment < ActiveRecord::Base

  belongs_to :source_headline
  belongs_to :headline

  scope :ordered, -> { order("index asc") }

  def fragment
    f = source_headline.name[source_headline_start...source_headline_end]

    # Try to get the original capitalization
    i = headline.name.downcase.index(f.downcase)
    return headline.name[i...(i + f.length)] if i

    f
  end

  def source
    source_headline.source
  end

end
