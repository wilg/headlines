namespace :tweetbot do

  task tweet: :environment do
    headlines = Headline.where(bot_shared_at: nil).where("vote_count > 5").order('random()').limit(5)
    headlines.each do |headline|
      headline.tweet_from_bot!
    end
  end

end
