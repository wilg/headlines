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

  def active_if_param(param_name, param_value, also_if_blank = false)
    params[param_name].to_s == param_value.to_s || also_if_blank && params[param_name].blank? ? 'active' : ''
  end

  def default_button_toggle(*args)
    "btn btn-default " + active_if_param(*args)
  end

end
