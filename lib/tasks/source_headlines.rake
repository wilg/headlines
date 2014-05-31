namespace :source_headlines do

  task resave: :environment do
    g = 0
    n = 0
    count = SourceHeadline.count
    SourceHeadline.find_in_batches do |group|
      group.each_with_index do |headline, i|
        print "#{n} / #{count} (#{((n.to_f/count.to_f) * 100.0).round(1)}%) \r"
        $stdout.flush
        headline.save!
        n += 1
      end
      g += 1
    end
  end

  task resave_unhashed: :environment do
    g = 0
    n = 0
    count = SourceHeadline.where(name_hash: nil).count
    SourceHeadline.where(name_hash: nil).find_in_batches do |group|
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
