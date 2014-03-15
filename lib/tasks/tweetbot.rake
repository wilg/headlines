namespace :tweetbot do

  task tweet: :environment do

    tweet_every = 3.02.hours

    if Headline.last_bot_tweet > tweet_every.ago
      puts "Too soon for a tweet!"
    else

      # Prefer my own sense of humor
      headline = User.find(1).upvoted_headlines.where(bot_shared_at: nil).order('random()').first

      # Then popular ones
      headline = Headline.where(bot_shared_at: nil).order('random()').where("vote_count > 10").first unless headline

      headline.tweet_from_bot!

    end

  end

end
