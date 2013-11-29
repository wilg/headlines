headlines = []

# RSS
# require 'rss'
# response = RSS::Parser.parse("http://feeds.feedburner.com/upworthy", false)
# headlines += response.channel.items.map(&:title)


# Scrape
require 'nokogiri'
require 'open-uri'
begin
  (361..700).each do |i|
    doc = Nokogiri::HTML(open("http://www.upworthy.com/page/#{i}"))
    puts "==> PAGE #{i} / #{headlines.length} headlines"
    doc.css('.nugget-info h3 a').each do |link|
      puts link.content unless headlines.include?(link.content)
      headlines << link.content
    end
  end
rescue
  puts "ERROR!!!!!!"
end

headlines.uniq!

# Write to file

File.open("upworthy.txt", 'w') {|f| f.write(headlines.join("\n")) }