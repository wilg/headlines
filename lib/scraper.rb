require 'nokogiri'
require 'open-uri'

class Scraper

  def write_file
    File.open("#{self.class.to_s}.txt", 'w') {|f| f.write(@headlines.uniq.join("\n")) }
  end

  def scrape_page(i)
    # add_headline! foo
  end

  def add_headline!(headline)
    headline = headline.chomp.strip
    unless @headlines.include?(headline)
      puts "-> " + headline
      @headlines << headline
    end
  end

  def scrape!(range = (1..200))
    @headlines = []
    range.each do |i|
      begin
        puts "Scraping page #{i} | #{@headlines.length} headlines found"
        scrape_page(i)
        write_file
      rescue => e
        puts "*** Failed on page #{i}"
        puts e.to_s
      end
    end
  end

end