class SourceHeadlineFragment < ActiveRecord::Base

  belongs_to :source_headline
  belongs_to :headline

  scope :ordered, -> { order("index asc") }

  def fragment
    f = source_headline.name[source_headline_start...source_headline_end]

    # raise f if source_headline.id != 46361

    # Try to get the original capitalization
    normalized_name = self.class.normalize(headline.name)
    normalized_fragment = self.class.normalize(f)
    i = normalized_name.index(normalized_fragment)
    return headline.repunctuated_name[i...(i + normalized_fragment.length)] if i

    f
  end

  def source
    source_headline && source_headline.source
  end

  def self.normalize(string)
    Headline.normalize_smart_quotes(string.downcase)
  end

end
