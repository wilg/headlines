module GeneratorHelper

  def generator_sources
    HeadlineSource.all.reject{|s| s.dead }.sort_by{|s| s.category}.group_by{|s| s.category }
  end

  def generate_url_like(headline)
    return generator_url unless headline && headline.sources.present?
    generator_url(Hash[headline.sources.map{|s| [s.id, 1]}])
  end

  def generator_all_sources
    HeadlineSource.all.reject{|s| s.dead }.map do |source|
      [source.id, {
        id: source.id,
        image_url: source_image_url(source),
        name: source.name
      }]
    end.to_h
  end

end
