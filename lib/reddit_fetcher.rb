require_relative 'fetcher'
require 'snoo'

class RedditFetcher < Fetcher

  def subreddit
    ''
  end

  def fetch!
    super

    reddit = Snoo::Client.new

    while true
      begin
        puts "Scraping listing after #{@progress} | #{@headlines.length} headlines found"

        listing = reddit.get_listing(subreddit: subreddit, t: 'all', page: 'top', sort: 'top', limit: 100, after: @progress)
        listing['data']['children'].each do |item|
          add_headline! item['data']['title']
          @progress = item['data']['name']
        end

        write_file
      rescue => e
        puts "*** Failed on item #{@progress}"
        puts e.to_s
      end
    end


  end


end