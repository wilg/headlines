module HeadlinesHelper

  def can_vote?(headline)
    session[:votes].blank? || !session[:votes].include?(headline.id)
  end

  def sources_includes?(source_name)
    @sources.present? && @sources.include?(source_name.to_sym)
  end

end
