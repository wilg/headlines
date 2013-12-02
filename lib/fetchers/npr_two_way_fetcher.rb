require_relative '../scraper'

class NPRTwoWayFetcher < Scraper

  def scrape_page(i)
    doc = Nokogiri::HTML(open("http://www.npr.org/aggregation/103943429/storylist?page=#{i}&live=1"))
    doc.css('article h1 a').each do |link|
      add_headline! link.content
    end
  end

end

NPRTwoWayFetcher.new.fetch!