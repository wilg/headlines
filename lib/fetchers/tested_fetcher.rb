require_relative '../scraper'

class TestedFetcher < Scraper

  def scrape_page(i)
    doc = Nokogiri::HTML(open("http://www.tested.com/?&p=#{i}"))
    doc.css('article header a.title').each do |link|
      add_headline! link.content
    end
  end

end

TestedFetcher.new.fetch!