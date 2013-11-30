require_relative '../reddit_fetcher'

class RPoliticsFetcher < RedditFetcher

  def subreddit
    'politics'
  end

end

RPoliticsFetcher.new.fetch!