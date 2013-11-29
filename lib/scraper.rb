require_relative 'fetcher'

class Scraper < Fetcher

  def fetch!
    super
    i = @progress || 0
    while true
      begin
        puts "Scraping page #{i} | #{@headlines.length} headlines found"
        scrape_page(i)
        @progress = i
        write_file
      rescue => e
        puts "*** Failed on page #{i}"
        puts e.to_s
      end
      i = i + 1
    end
  end

  def scrape_page(i)
    # add_headline! foo
  end

end