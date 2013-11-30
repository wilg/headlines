require_relative '../scraper'

class HuffpostBlogsFetcher < Scraper

  def scrape_page_and_progress(date)
    date = Date.today if date == 0
    doc = Nokogiri::HTML(open("http://www.huffingtonpost.com/politics/the-blog/#{date.strftime("%Y/%m/%d")}/"))
    doc.css('.entry_right h3 a').each do |link|
      add_headline! link.content
    end
    return date.prev_day
  end

end

HuffpostBlogsFetcher.new.fetch!