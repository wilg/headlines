json.extract! source_headline, :id, :name
json.source do
  json.id source_headline.source.id
  json.name source_headline.source.name
end
json.url source_headline_url(source_headline)
json.article_url source_headline.article_url