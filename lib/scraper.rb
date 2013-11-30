require_relative 'fetcher'

class Scraper < Fetcher

  def fetch!
    super
    @progress = @progress || 0
    while true
      begin
        puts "Scraping page #{@progress} | #{@headlines.length} headlines found"
        @progress = scrape_page_and_progress(@progress)
        write_file
      rescue => e
        puts "*** Failed on page #{@progress}"
        puts e.to_s
      end
    end
  end

  def scrape_page_and_progress(progress)
    scrape_page(progress)
    return progress + 1
  end

  def scrape_page(page_number)
    # add_headline! foo
  end

end