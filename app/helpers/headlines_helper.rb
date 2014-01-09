module HeadlinesHelper

  def headlines_sorted_by_params(headlines, defaults = {order: :top, timeframe: :all, q: nil})
    # Get the params from the request and merge them with the defaults
    sort_order     = (params[:order].presence || defaults[:order]).to_sym
    sort_timeframe = (params[:timeframe].presence || defaults[:timeframe]).to_sym
    query          = params[:q].presence || defaults[:q].presence

    if sort_order == :new
      headlines = headlines.newest
    elsif sort_order == :trending
      headlines = headlines.hot
    elsif sort_order == :top
      @sorting_top = true
      headlines = headlines.top
      if sort_timeframe == :all
      elsif sort_timeframe == :yesterday
        headlines = headlines.yesterday
      elsif sort_timeframe == :this_week
        headlines = headlines.this_week
      elsif sort_timeframe == :today
        headlines = headlines.today
      end
    end

    if query
      headlines = headlines.where("headlines.name ilike (?)", "%#{query}%")
    end

    headlines
  end

  def merge_sort_url(new_params)
    merged = params.merge(new_params)
    merged.delete(:page) if params[:page].blank? || merged[:page].to_i == 1
    merged
  end

  def default_pagination(scope)
    scope.paginate(:page => params[:page], :per_page => 40)
  end

  def tooltipped_headline(headline, options = {})
    options = {inner_linked: false}.merge(options)
    if headline.source_headline_fragments.length > 0
      render partial: 'headlines/tooltips/outer', locals: {headline: headline, options: options}
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

  def main_button_best_toggle(value, also_if_blank = false)
    k = "btn btn-lg btn-default "
    k << active_if_param(:order, value, also_if_blank) if @is_main_browse_page
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

  def facebook_share_url(headline)
    "https://www.facebook.com/sharer/sharer.php?u=#{headline_url(headline)}"
  end

  def loading_icon
    "..."
  end

end
