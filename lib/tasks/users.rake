namespace :users do

  task resave: :environment do
    g = 0
    n = 0
    count = User.count
    User.top.find_in_batches do |group|
      group.each_with_index do |user, i|
        print "#{n} / #{count} (#{((n.to_f/count.to_f) * 100.0).round(1)}%) \r"
        $stdout.flush
        user.save!
        n += 1
      end
      g += 1
    end
  end

end
