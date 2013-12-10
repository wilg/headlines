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

end
