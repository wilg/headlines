TWEET_EVERY = 3.03.hours
RETWEET_AFTER = 1.year
RETWEET_EVERY = 26.hours
MIN_VOTES = 10

namespace :tweetbot do

  task :tweet_and_fetch => ["tweetbot:tweet", "tweetbot:fetch_tweet_metadata", "tweetbot:fetch_mentions"]

  task tweet: :environment do

    if Headline.last_tweet_time > TWEET_EVERY.ago
      puts "Too soon for a tweet!"
    else

      # Prefer my own sense of humor
      headline = User.find(1).upvoted_headlines.tweetable.order('random()').first

      # Then popular ones
      headline = Headline.tweetable.order('random()').where(["vote_count >= ?", MIN_VOTES]).first unless headline

      headline.tweet_from_bot!

    end

    if Headline.last_retweet_time > RETWEET_EVERY.ago
      puts "Too soon for a retweet!"
    else
      retweet_headline = Headline.retweetable.where(["retweeted_at is null OR retweeted_at < ?", RETWEET_EVERY.ago]).where(["vote_count >= ?", MIN_VOTES]).order('random()').first
      retweet_headline.retweet_from_bot! if retweet_headline
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
