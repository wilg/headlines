module SourcesHelper

  def read_link_data(source_headline)
    return nil unless source_headline && source_headline.source
    d = {
      id: source_headline.id,
      source: source_headline.source.id
    }
    d[:headline_id] = @headline.id if @headline
    d
  end

end
