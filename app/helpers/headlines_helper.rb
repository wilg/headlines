module HeadlinesHelper

  def can_vote?(headline)
    session[:votes].blank? || !session[:votes].include?(headline.id)
  end

  def selected_sources_includes?(source)
    @sources.present? && @sources.include?(source.id)
  end

  def source_image_tag(source)
    image_tag("#{source.id}.png", class: 'source-icon', alt: source.name)
  end

  def active_if_param(param_name, param_value, also_if_blank = false)
    params[param_name].to_s == param_value.to_s || also_if_blank && params[param_name].blank? ? 'active' : ''
  end

  def default_button_toggle(*args)
    "btn btn-default " + active_if_param(*args)
  end

end
