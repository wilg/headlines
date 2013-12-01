require 'nokogiri'
require 'open-uri'
require 'yaml'

class Fetcher

  def fetch!
    @headlines = current_contents.uniq
    @progress  = YAML.load_file(progress_file_path)[id] || 0

    puts "Starting from progress #{@progress} with #{@headlines.uniq.count} unique headlines."

    # Subclass me!
  end

  def dictionary_path
    File.expand_path("../dictionaries/#{id}.txt", __FILE__)
  end

  def current_contents
    if File.exists? dictionary_path
      File.readlines(dictionary_path).map{|l| l.chomp.strip}
    else
      []
    end
  end

  def id
    path = self.class.instance_methods(false).map { |m|
      self.class.instance_method(m).source_location.first
    }.uniq.first
    File.basename(path).split("_fetcher").first
  end

  def add_headline!(headline)
    headline = headline.chomp.strip
    unless @headlines.include?(headline)
      puts "-> " + headline
      @headlines << headline
    end
  end

  def is_valid?(headline)
    headline[-1, 1] != "…" # We don't want pre-truncated headlines
  end

  def write_file
    headlines = @headlines.uniq.select{|x| is_valid?(x) }
    File.open(dictionary_path, 'w') {|f| f.write(headlines.join("\n")) }
    write_progress
  end

  def progress_file_path
    File.expand_path("fetch_progress.yml", File.dirname(__FILE__))
  end

  def write_progress
    prog = YAML.load_file(progress_file_path)
    prog[id] = @progress
    File.open(progress_file_path, 'w') {|f| f.write prog.to_yaml }
  end

  def current_progress
    YAML.load_file(progress_file_path)[id] || nil
  end

end