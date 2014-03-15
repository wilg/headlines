class Reconstruct

  require 'colorize'

  def self.export
    puts "Count: #{Headline.no_metadata.count}"
    Headline.no_metadata.top.pluck(:name).each do |n|
      puts n
    end
    true
  end

  def self.download_json(url)
    require 'open-uri'
    import_json(open(url, &:read))
  end

  def self.import_json(json)
    import JSON.parse(json)['headlines']
  end

  def self.import(array_from_json)

    array_from_json.each do |headline_hash|

      @headline = Headline.with_name(headline_hash['headline']).includes(:source_headline_fragments).first

      if @headline
        begin
          if @headline.source_headline_fragments.size == 0
            @headline.create_sources!(headline_hash['sources'])
            puts "[SUCCESS] Headline #{@headline.id} - Added souces".green
          else
            puts "[ERROR] [ALREADY_DONE] Headline #{@headline.id} - Already had sources".red
          end
        rescue Exception => e
          puts "[ERROR] [EXCEPTION] #{e}".red
        end
      else
        puts "[ERROR] [NO_HEADLINE] Couldn't find headline for name #{headline_hash['headline']}".red
      end

    end

    puts 'Done!'.green
  end

end