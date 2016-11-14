namespace :tweetbot do

  task :tweet_and_fetch => ["tweetbot:tweet", "tweetbot:fetch_tweet_metadata", "tweetbot:fetch_mentions"]

  task tweet: :environment do

    tweet_every = 3.03.hours

    if Headline.last_bot_tweet > tweet_every.ago
      puts "Too soon for a tweet!"
    else

      # Prefer my own sense of humor
      headline = User.find(1).upvoted_headlines.tweetable.order('random()').first

      # Then popular ones
      headline = Headline.tweetable.order('random()').where("vote_count > 10").first unless headline

      headline.tweet_from_bot!

    end

  end

  task fetch_tweet_metadata: :environment do

    ids = Headline.tweeted.order("bot_shared_at desc").limit(ENV['TWEET_LIMIT'] || 500).pluck(:bot_share_tweet_id)
    tweets = TWITTER_BOT_CLIENT.statuses(ids)

    tweets.each do |tweet|
      headline = Headline.find_by bot_share_tweet_id: tweet.id
      headline.retweet_count = tweet.retweet_count
      headline.favorite_count = tweet.favorite_count
      headline.save!
      puts "Updated headline #{headline.bot_share_tweet_id}."
    end

  end

  task fetch_mentions: :environment do
    HeadlineTwitterMention.import_recent
  end

end
