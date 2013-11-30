require_relative '../reddit_fetcher'

class RFunnyFetcher < RedditFetcher

  def subreddit
    'funny'
  end

end

RFunnyFetcher.new.fetch!