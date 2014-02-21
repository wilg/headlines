namespace :tweetbot do

  task tweet: :environment do

    # Authenticate Requests
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_BOT_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_BOT_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_BOT_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_BOT_ACCESS_TOKEN_SECRET']
    end

    # Include URL Helpers
    include Rails.application.routes.url_helpers
    default_url_options[:host] = 'www.headlinesmasher.com'

    headlines = Headline.where(bot_shared_at: nil).where("vote_count > 5").order('random()').limit(5)

    headlines.each do |headline|
      tweet = client.update("#{headline.name} #{url_for(headline)}")
      headline.bot_shared_at = Time.now
      headline.bot_share_tweet_id = tweet.id
      headline.save
    end

  end

end
