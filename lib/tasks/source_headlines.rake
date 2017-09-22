namespace :source_headlines do

  task trim: :environment do
    budget = Integer(ENV["MAX_UNUSED_SOURCE_HEADLINES"])
    puts "Trimming source headlines to a max of #{budget}"

    unused_count = SourceHeadline.unused.count
    puts "There are #{unused_count} headlines in the database"

    over_budget_amount = unused_count - budget
    if over_budget_amount > 0
      puts "We are over budget by #{over_budget_amount} source headlines"

      total_deleted = 0
      # Order is, according to rails, id asc
      SourceHeadline.unused.find_in_batches do |group|
        SourceHeadline.delete(group.map(&:id))
        total_deleted += group.length
        puts "Deleted #{total_deleted}/#{over_budget_amount} source headlines."
        break if total_deleted >= over_budget_amount
      end

    else
      puts "We are under budget by #{over_budget_amount.abs}. Exiting."
    end

  end

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

  task deduplicate: :environment do
    require 'colorize'

    duplicated_hashes = SourceHeadline.select(:name_hash).group(:name_hash).having("count(*) > 1").order("RANDOM()").count
    total = duplicated_hashes.length
    total_kept = 0
    total_deleted = 0
    i = 0
    duplicated_hashes.each do |duped_hash, dupe_count|
      puts "#{i}/#{total} (#{((i.to_f/total.to_f) * 100.0).round(1)}%) - #{total_deleted} deleted - #{total_kept} kept"
      puts "#{duped_hash} (#{dupe_count} copies)"
      dupes = SourceHeadline.where(name_hash: duped_hash)
      deleted_here = 0

      dupes.each_with_index do |dupe, index|
        count = dupe.headlines.count
        if count > 0
          puts "   -> Dupe #{index} - Has #{count} headlines".red
        elsif index > 0
          dupe.destroy!
          deleted_here += 1
          puts "   -> Dupe #{index} - Deleted".green
        else
          puts "   -> Dupe #{index} - Kept".yellow
        end
      end

      varying = dupes.map{|d| d.name.downcase.gsub(/\u00a0/, ' ')}.uniq.length > 1
      varying_length = dupes.map{|d| d.name.length }.uniq.length > 1
      if !varying || !varying_length
        alive = dupes.reject(&:destroyed?)
        if alive.length > 1
          puts "   -> Identical titles, combining".cyan
          canonical_dupe = alive.first
          alive.each_with_index do |dupe, index|
            if index > 0
              dupe.source_headline_fragments.update_all(source_headline_id: canonical_dupe.id)
              dupe.destroy!
              deleted_here += 1
              puts "   -> Merged #{dupe.id} into #{canonical_dupe.id}".green
            end
          end
        end
      else
        dupes.each{|d| puts d.name.downcase}
      end

      total_deleted += deleted_here
      total_kept += dupe_count - deleted_here

      i += 1
    end

  end

end
