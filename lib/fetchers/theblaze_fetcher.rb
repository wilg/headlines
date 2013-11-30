require_relative '../scraper'

class TheBlazeFetcher < Scraper

  def scrape_page(i)
    doc = Nokogiri::HTML(open("http://www.theblaze.com/stories/page/#{i}/"))
    doc.css('.story.blog-post h5').each do |link|
      add_headline! link.content
    end
  end

end

TheBlazeFetcher.new.fetch!