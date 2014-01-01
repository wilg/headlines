class Reconstruct

  require 'colorize'

  def self.export
    no_metadata = Headline.includes(:source_headline_fragments).where(:source_headline_fragments => {:headline_id =>nil} )
    puts "Count: #{no_metadata.count}"
    no_metadata.each do |h|
      puts h.name
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

      @headline = Headline.with_name(headline_hash['headline']).first

      if @headline
        if @headline.source_headline_fragments.size == 0
          @headline.create_sources!(headline_hash['sources'])
          puts "Headline #{@headline.id} - Added souces".green
        else
          puts "Headline #{@headline.id} - FAILED - Already had sources".red
        end
      else
        puts "Couldn't find headline for name #{headline_hash['headline']}".red
      end

    end

    puts 'Done!'.green
  end

end