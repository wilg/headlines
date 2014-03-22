namespace :stats do
  task wordcount: :environment do

    require "csv"

    data = Headline.limit(20).pluck(:name, :vote_count).map do |d|
      d[0].squish.downcase.gsub(/[^0-9a-z ]/i, '').split(' ').map do |d2|
        {word: d2, vote_count: d[1]}
      end
    end.flatten

    word_counts = data.reduce(Hash.new(0)) do |results, d|
      results[d[:word]] = {vote_count: 0, word_count: 0} unless results[d[:word]]
      results[d[:word]][:vote_count] += d[:vote_count]
      results[d[:word]][:word_count] += 1
      results
    end

    word_counts.sort! {|a, b| b[:vote_count] <=> a[:vote_count] }

    CSV.open(File.join(Rails.root, 'tmp', 'wordcount.csv'), 'wb') do |csv|
      word_counts.each do |line|
        csv << line.map{|k, v| v.merge({word: k})}
      end
    end

  end
end
