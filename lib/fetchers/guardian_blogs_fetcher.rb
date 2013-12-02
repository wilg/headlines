require_relative '../scraper'

class GuardianBlogsFetcher < Scraper

  def scrape_page(i)
    doc = Nokogiri::HTML(open("http://www.theguardian.com/news/blog?page=5#{i}"))
    doc.css('#blog-posts-excerpts li h3 a').each do |link|
      add_headline! link.content
    end
  end

end

GuardianBlogsFetcher.new.fetch!