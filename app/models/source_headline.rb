class SourceHeadline < ActiveRecord::Base

  has_many :source_headline_fragments, dependent: :nullify
  has_many :headlines, through: :source_headline_fragments

  def source
    Source.find(source_id)
  end

  def article_url
    q = "#{name} #{source.name}"
    url || "https://www.google.com/search?btnI&q=#{CGI.escape(q)}&safe=off"
  end

end
