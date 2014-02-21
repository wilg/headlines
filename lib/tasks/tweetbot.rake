namespace :tweetbot do

  task tweet: :environment do

    tweet_every = 4.hours

    if Headline.last_bot_tweet > tweet_every.ago
      puts "Too soon for a tweet!"
    else
      headline = Headline.where(bot_shared_at: nil).where("vote_count > 10").order('random()').first
      headline.tweet_from_bot!
    end

  end

end
