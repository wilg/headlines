require_relative 'scraper'

class BuzzfeedScraper < Scraper

  def scrape_page(i)
    doc = Nokogiri::HTML(open("http://www.buzzfeed.com/plugin/midcolumn/v:1.0/p:#{i}"))
    doc.css('h3 a span').each do |link|
      add_headline! link.content
    end
    doc2 = Nokogiri::HTML(open("http://www.buzzfeed.com/index/paging?p=#{i}"))
    doc2.css('hgroup h2 a').each do |link|
      add_headline! link.content
    end
  end

end

BuzzfeedScraper.new.scrape!