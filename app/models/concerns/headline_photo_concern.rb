module HeadlinePhotoConcern
  extend ActiveSupport::Concern

  TRUMP_WORDS = ['obama', 'texas', 'california', 'moon', 'robot', 'police', 'cop', 'sheriff', 'dog', 'cat', 'chimp', 'baby', 'oprah', 'romney', 'wedding', 'insect', 'nintendo', 'xbox', 'bitcoin', 'halloween', 'disney', 'hitler', 'stripper', 'sex', 'baby', 'babies', 'bacon', 'god', 'jesus', 'mario']

  IGNORED_WORDS = ['announcement', 'this', 'please', 'his', 'hers', 'him', 'her', 'a', 'the', 'them', 'of', 'your', 'on', 'an', 'i', 'but', 'here', 'cant', 'can', 'continues', 'continue', 'another', 'remarkable', 'example', 'in', 'into', 'now', 'is', 'story', 'many', 'actually', 'really', 'you', 'seriously', 'new', 'by', 'before', 'does', 'turning', 'that', 'will', 'all', 'us', 'something','resembles','basically','about','might','have', 'we', 'may', 'be', 'fact', 'why']

  def to_tag
    short_name = name.parameterize.gsub("-s-", "s-").gsub("-t-", "t-").split("-").reject{|w| IGNORED_WORDS.include?(w) }.uniq
    def length_with_bonus(str)
      bonus = 0
      bonus = 5 if TRUMP_WORDS.include?(str) || TRUMP_WORDS.include?(str.pluralize)
      str.length + bonus
    end
    return short_name.compact.sort{|a, b| length_with_bonus(b) <=> length_with_bonus(a)}.first(6).join(",")
  end

  def has_photo?
    photo_data.present? && photo_data['flickr'].present?
  end

  def needs_photo_load?
    photo_data.present? && photo_data['flickr'] != false
  end

  def find_photo!(search = to_tag)
    photo = flickr.photos.search(tags: search, per_page: 20, sort: 'relevance', media: 'photos', extras: "owner_name,license").to_a.sample
    set_photo!(photo.try(:to_hash))
  end

  def set_photo!(photo_hash)
    if photo_hash
      photo_data['flickr'] = photo_hash
    else
      photo_data['flickr'] = false
    end
    save!
  end

  def clear_photo!
    photo_data = {}
    save!
  end

  def image_url!(*args)
    find_photo! unless needs_photo_load?
    image_url(*args)
  end

  def image_url(size = 'q', return_bullshit_image = true)
    size = size.nil? ? "" : "_#{size}"
    if has_photo?
      r = photo_data['flickr']
      FlickRaw::PHOTO_SOURCE_URL % [r['farm'], r['server'], r['id'], r['secret'], size, "jpg"]
    else
      return nil unless return_bullshit_image
      return "http://lorempixel.com/150/150" if size == 'q'
      "http://lorempixel.com/400/200"
    end
  end

  def image_owner
    photo_data['flickr']['ownername'] if has_photo? && photo_data['flickr']['ownername'].present?
  end

  def image_info_url
    FlickRaw.url_photopage FlickRaw::Response.build(photo_data['flickr'], 'photo')
  end

end
