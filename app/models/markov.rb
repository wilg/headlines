require 'yaml'

class Markov

  @markov_map = {}
  @lookback = 2
  @source_sentences = []

  attr_reader :markov_map

  def initialize(source_sentences)
    build_map! source_sentences
  end

  def build_map!(source_sentences, lookback = 2)
    @source_sentences = source_sentences
    @lookback = lookback

    markov_map = {}

    # Generate map in the form word1 -> word2 -> occurences of word2 after word1
    @source_sentences.each do |title|
      title = title.split
      if title.length > lookback
        (title.length + 1).times do |i|
          a = title[([0, i - lookback].max)...i].join(' ')
          b = title[i...i+1].join(' ')
          markov_map[a]    = {} if markov_map[a].nil?
          markov_map[a][b] = 0 if markov_map[a][b].nil?
          markov_map[a][b] = markov_map[a][b] + 1
        end
      end
    end

    # Convert map to the word1 -> word2 -> probability of word2 after word1
    markov_map.each do |word, following|
      total = following.values.reduce(:+).to_f # sum
      following.each_key do |key|
        following[key] /= total
      end
    end

    @markov_map = markov_map

  end

  # Typical sampling from a categorical distribution
  def markov_sample(items)
    items = {} unless items
    next_word = nil
    t = 0.0
    items.each do |k, v|
      t += v
      next_word = k if t > 0 && rand() < v / t
    end
    next_word
  end

  def get_sentence(length_max = 140)
    mapkeys = @markov_map.keys
    while true
      sentence = []
      next_word = mapkeys.sample
      while next_word != '' && next_word != nil
        sentence << next_word
        next_word = markov_sample(@markov_map[sentence.last(@lookback).join(' ')])
      end
      sentence = sentence.join(' ')

      # Prune titles that are substrings of actual titles
      next if @source_sentences.any?{|title| title.include?(sentence) }

      next if sentence.length > length_max

      return sentence
    end
  end

end

# path = File.expand_path("../../../lib/dictionaries/hackernews.txt", __FILE__)
# sources = File.readlines(path).map{|l| l.chomp.strip}

# markov = Markov.new(sources)
# 10.times { puts markov.get_sentence }