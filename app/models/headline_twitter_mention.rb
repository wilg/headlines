class HeadlineTwitterMention < ActiveRecord::Base

  belongs_to :headline, counter_cache: :mention_count

  validates :tweet_id, uniqueness: { scope: :headline_id }

  def self.import_recent
    tweets = TWITTER_BOT_CLIENT.search("headlinesmasher.com", result_type: "recent")
    tweets.each do |tweet|
      headlinesmasher_ids = tweet.uris.map do |uri|
        if ["www.headlinesmasher.com", "headlinesmasher.com"].include?(uri.expanded_url.hostname)
          parts = uri.expanded_url.path.split("/")
          if parts.length == 2 || (parts.length == 3 && parts[1] == "headlines")
            next parts.last
          end
        end
        nil
      end.compact

      headlinesmasher_ids.each do |headlinesmasher_id|
        headline = Headline.find(headlinesmasher_id) rescue nil
        if headline
          mention = self.where(headline: headline, tweet_id: tweet.id).first_or_create
          mention.update_attributes(created_at: tweet.created_at, twitter_username: tweet.user.screen_name)
        end
      end
    end
  end

  def tweet_url
    "https://twitter.com/#{twitter_username}/status/#{tweet_id}"
  end

end
