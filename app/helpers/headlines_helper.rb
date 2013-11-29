module HeadlinesHelper

  def can_vote?(headline)
    session[:votes].blank? || !session[:votes].include?(headline.id)
  end

  def sources_includes?(source_name)
    @sources.present? && @sources.include?(source_name.to_sym)
  end

  def source_image_tag(source_name)
    image_tag("#{source_name}.png", class: 'source-icon')
  end

end
