module GeneratorHelper

  def generator_sources
    HeadlineSources::Source.all.reject{|s| s.dead }.sort_by{|s| s.category}.group_by{|s| s.category }
  end

  def generate_url_like(headline)
    return generator_url unless headline && headline.sources.present?
    generator_url(Hash[headline.sources.map{|s| [s.id, 1]}])
  end

end
