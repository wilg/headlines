module ApplicationHelper

  include TweetButton

  def og!(k, v)
    @open_graph_tags = {} unless @open_graph_tags
    @open_graph_tags[k] = v
  end

  def og_tags
    default = {"og:site_name" => "Headline Smasher"}
    @open_graph_tags ? default.merge(@open_graph_tags) : default
  end

end
