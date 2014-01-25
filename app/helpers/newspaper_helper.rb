module NewspaperHelper

  def lazy_image_tag(url, options={})
    options = options.merge({data: {original: url}})
    image_tag(image_url("placeholder.png"), options)
  end

  def headline_image_tag(headline, options={})
    options = options.merge({})
    lazy_image_tag(headline.image_url(options), options)
  end

end
