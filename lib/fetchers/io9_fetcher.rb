require_relative '../scraper'

class Io9Fetcher < Scraper

  def scrape_page_and_progress(progress)
    doc = Nokogiri::HTML(open("http://io9.com/?startTime=#{progress}"))
    doc.css('.headline a').each do |link|
      add_headline! link.content
    end
    return doc.css("a.load-more-link").first["href"].split("=").last
  end

end

Io9Fetcher.new.fetch!