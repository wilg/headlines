require_relative '../scraper'

class CNNBlogsFetcher < Scraper

  def scrape_page(i)
    doc = Nokogiri::HTML(open("http://news.blogs.cnn.com/page/#{i}/"))
    doc.css('.cnnBlogContentTitle a').each do |link|
      add_headline! link.content
    end
  end

end

CNNBlogsFetcher.new.fetch!