require_relative '../scraper'

class TMZFetcher < Scraper

  def scrape_page(i)
    doc = Nokogiri::HTML(open("http://www.tmz.com/page/#{i}/"))
    doc.css('article a.headline').each do |link|
      add_headline! link.content.gsub(/\s+/, ' ').chomp.strip
    end
  end

end

TMZFetcher.new.fetch!