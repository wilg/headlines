headlines = []

def write_file(headlines)
  headlines.uniq!
  # Write to file
  File.open("buzzfeed_scrape.txt", 'w') {|f| f.write(headlines.join("\n")) }
end

# Scrape
require 'nokogiri'
require 'open-uri'
(0..1000).each do |i|
  puts "==> iteration #{i} / #{headlines.length} headlines"

  begin
    doc = Nokogiri::HTML(open("http://www.buzzfeed.com/plugin/midcolumn/v:1.0/p:#{i}"))
    doc.css('h3 a span').each do |link|
      puts link.content unless headlines.include?(link.content)
      headlines << link.content
    end
    write_file(headlines)
  rescue => e
    puts e
    puts "ERROR 1!!!!!!"
  end

  begin
    doc2 = Nokogiri::HTML(open("http://www.buzzfeed.com/index/paging?p=#{i}"))
    doc2.css('hgroup h2 a').each do |link|
      puts link.content unless headlines.include?(link.content)
      headlines << link.content
    end
    write_file(headlines)
  rescue => e
    puts e
    puts "ERROR 2!!!!!!"
  end

end
