module HeadlinesHelper

  def tooltipped_headline(headline, options = {})
    options = {linked: true}.merge(options)
    if headline.source_headline_fragments.length > 0
      render partial: 'headlines/tooltips/outer', locals: {headline: headline, linked: options[:linked]}
    else
      headline.name
    end
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

  def main_button_best_toggle(*args)
    k = "btn btn-lg btn-default "
    k << active_if_param(*args) if params[:action].to_sym == :best
    k
  end

  def main_button_best_toggle_phone(*args)
    k = "btn btn-sm btn-default "
    k << active_if_param(*args) if params[:action].to_sym == :best
    k
  end

  def tweet_url(headline)
    "https://twitter.com/intent/tweet?text=#{CGI.escape headline.name}&source=#{CGI.escape "Headline Smasher"}&url=#{headline_url(headline)}"
  end

  def loading_icon
    "..."
  end

end
