module HeadlinePhotoConcern
  extend ActiveSupport::Concern

  TRUMP_WORDS = %w[
    obama texas california moon robot police cop sheriff dog cat chimp baby oprah romney wedding insect nintendo xbox bitcoin halloween disney hitler stripper sex baby babies bacon god jesus mario space
  ]

  IGNORED_WORDS = %w[
    a about actually after all an and announcement another basically be before being but by can cant continue continues does example fact have he her here hers him his i in into is least many may might new now of on please rape really remarkable resembles seriously she something story that the them they this to turning us we why will with you your entire
  ]

  def tags
    short_name = name.parameterize.gsub("-s-", "s-").gsub("-t-", "t-").split("-").reject do |w|
      IGNORED_WORDS.include?(w) || (w.upcase != w && w.length < 3)
    end.uniq

    def length_with_bonus(str)
      bonus = 0
      bonus = 10 if TRUMP_WORDS.include?(str) || TRUMP_WORDS.include?(str.pluralize)
      str.length + bonus
    end

    short_name.compact.sort{|a, b| length_with_bonus(b) <=> length_with_bonus(a)}.first(6)
  end

  def has_photo?
    photo_data.present? && photo_data['flickr'].present?
  end

  def needs_photo_load?
    photo_data.present? && photo_data['flickr'] != false
  end

  def find_photo!(search = tags.first)
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
