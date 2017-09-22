class SourceHeadline < ActiveRecord::Base

  require 'headline_sources/headline'

  has_many :source_headline_fragments, dependent: :nullify
  has_many :headlines, through: :source_headline_fragments

  before_save do
    self.name_hash = HeadlineSources::Headline.headline_hash(self.name)
  end

  def source
    @source ||= HeadlineSource.find(source_id)
  end

  def article_url
    q = "#{name} #{source.name if source}"
    url || "https://www.google.com/search?btnI&q=#{CGI.escape(q)}&safe=off"
  end

  def pretty_author
    return nil if !author || author.include?("@")
    author.gsub(/By /i, '')
  end

  def self.unused
    includes(:source_headline_fragments).where(source_headline_fragments: {id: nil})
  end

  def self.used
    includes(:source_headline_fragments).where.not(source_headline_fragments: {id: nil})
  end

end
