require_relative '../scraper'

class NYTimesLedeFetcher < Scraper

  def scrape_page(i)
    doc = Nokogiri::HTML(open("http://thelede.blogs.nytimes.com/page/#{i}/"))
    doc.css('h3.entry-title a').each do |link|
      add_headline! link.content
    end
  end

end

NYTimesLedeFetcher.new.fetch!