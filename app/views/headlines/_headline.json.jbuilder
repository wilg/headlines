json.extract! headline, :id, :score, :vote_count, :name, :created_at, :updated_at
json.url headline_url(headline)
json.author do
  if headline.creator.blank?
    json.null! # or json.nil!
  else
    json.username headline.creator.login
    json.url user_url(headline.creator)
  end
end
json.source_headlines do
  json.array! headline.source_headlines.uniq do |source_headline|
    json.partial! source_headline
  end
end
