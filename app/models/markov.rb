require 'yaml'

class Markov

  @source_sentences = []

  def initialize(source_sentences)
    build_map! source_sentences
  end

  attr_reader :markov_map

  @markov_map = {}
  @lookback = 2

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
  def sample(items)
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
    i = 0
    j = 0
    while true
      i += 1
      sentence = []
      next_word = @markov_map.keys.sample
      while next_word != '' && next_word != nil
        j+= 1
        sentence << next_word
        # puts "next = #{next_word}"
        next_word = sample(@markov_map[sentence.last(@lookback).join(' ')])
      end
      sentence = sentence.join(' ')

      # Prune titles that are substrings of actual titles
      next if @source_sentences.any?{|title|
        if title.include?(sentence)
          # puts "** #{sentence} ** is substring of ** #{title}"
          true
        else
          false
        end
      }

      next if sentence.length > length_max

      # puts "** #{i} outer iterations #{j} inner iterations"
      return sentence
    end
  end

end

path = File.expand_path("../../../lib/dictionaries/hackernews.txt", __FILE__)
sources = File.readlines(path).map{|l| l.chomp.strip}

markov = Markov.new(sources)
10.times { puts markov.get_sentence }

# dumppath = File.expand_path("../../../markov.yml", __FILE__)
# File.open(dumppath, 'w') {|f| f.write markov.markov_map.to_yaml }

# puts YAML.dump(markov.markov_map)

# archive = open("archive.txt")
# titles = archive.read().split("\n")
# archive.close()
# markov_map = defaultdict(lambda:defaultdict(int))

# lookback = 2

#Generate map in the form word1 -> word2 -> occurences of word2 after word1
# for title in titles[:-1]:
#     title = title.split()
#     if len(title) > lookback:
#         for i in xrange(len(title)+1):
#             markov_map[' '.join(title[max(0,i-lookback):i])][' '.join(title[i:i+1])] += 1

# #Convert map to the word1 -> word2 -> probability of word2 after word1
# for word, following in markov_map.items():
#     total = float(sum(following.values()))
#     for key in following:
#         following[key] /= total

# #Typical sampling from a categorical distribution
# def sample(items):
#     next_word = None
#     t = 0.0
#     for k, v in items:
#         t += v
#         if t and random() < v/t:
#             next_word = k
#     return next_word

# sentences = []
# while len(sentences) < 100:
#     sentence = []
#     next_word = sample(markov_map[''].items())
#     while next_word != '':
#         sentence.append(next_word)
#         next_word = sample(markov_map[' '.join(sentence[-lookback:])].items())
#     sentence = ' '.join(sentence)
#     flag = True
#     for title in titles: #Prune titles that are substrings of actual titles
#         if sentence in title:
#             flag = False
#             break
#     if flag:
#         sentences.append(sentence)

# for sentence in sentences:
#     print sentence

# end