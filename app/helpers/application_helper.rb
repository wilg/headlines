module ApplicationHelper

  include TweetButton

  def og!(k, v)
    @open_graph_tags = {} unless @open_graph_tags
    @open_graph_tags[k] = v if v
  end

  def og_tags
    default = {"og:site_name" => "Headline Smasher", "og:image" => image_url("logo-large.png")}
    @open_graph_tags ? default.merge(@open_graph_tags) : default
  end

  def cache_key_for_duration(duration, key)
    "#{key.to_s}_#{Time.now.to_i/(duration.to_i)*(duration.to_i)}"
  end

end
