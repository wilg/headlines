namespace :headlines do

  task resave: :environment do
    g = 0
    n = 0
    count = Headline.count
    Headline.top.find_in_batches do |group|
      group.each_with_index do |headline, i|
        print "#{n} / #{count} (#{((n.to_f/count.to_f) * 100.0).round(1)}%) \r"
        $stdout.flush
        headline.save!
        n += 1
      end
      g += 1
    end
  end

  task fake: :environment do
    Headline.where("bot_share_tweet_id LIKE \'fake-%\'").delete_all
    500.times do |i|
      vote_count = Faker::Number.between(1, 3)
      h = Headline.create!(
        name: Faker::Hipster.sentence,
        vote_count: vote_count,
        created_at: Faker::Time.backward(35),
        bot_share_tweet_id: "fake-#{i}"
      )
      vote_count.times do
        h.votes.create(value: 1)
      end
      h.vote_count = vote_count
      h.save!
      puts h.inspect
    end
  end

end
