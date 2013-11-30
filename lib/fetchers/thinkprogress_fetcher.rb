require_relative '../scraper'

class ThinkProgressFetcher < Scraper

  def scrape_page(i)
    doc = Nokogiri::HTML(open("http://thinkprogress.org/page/5#{i}/"))
    doc.css('.story-preview h4 a').each do |link|
      add_headline! link.content
    end
  end

end

ThinkProgressFetcher.new.fetch!