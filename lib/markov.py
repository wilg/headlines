from collections import defaultdict
from random import randint
from random import random
import os
import itertools
import sys

# Settings
max_corpus_size = 20000

# Accept args for different dictionaries
dicts = sys.argv
dicts.pop(0)

# Import depth
lookback = int(dicts.pop(0))

# import multiple dictionaries
dir = os.path.dirname(__file__)
imported_titles = []
per_dictionary_limit = max_corpus_size / len(dicts)
for dictionary_name in dicts:
    filename = os.path.join(dir, "dictionaries/" + dictionary_name + ".txt")

    archive = open(filename)
    dict_titles = archive.read().split("\n")
    archive.close()

    if len(dict_titles) > per_dictionary_limit:
        window_start = randint(0,len(dict_titles) - per_dictionary_limit)
        dict_titles = dict_titles[window_start:window_start+per_dictionary_limit]

    imported_titles = imported_titles + dict_titles


titles = []

# lowercase everything, remove quotes (to prevent dangling quotes)
# we're also going to create a mapping back to the original case if it's a weird word (like iPad)
titlecase_mappings = {}
for title in imported_titles:
    titles.append(title.lower().replace("\"", ""))
    for original_word in title.replace("\"", "").split(" "):
        titlecase_mappings[original_word.lower()] = original_word

markov_map = defaultdict(lambda:defaultdict(int))

#Generate map in the form word1 -> word2 -> occurences of word2 after word1
for title in titles[:-1]:
    title = title.split()
    if len(title) > lookback:
        for i in xrange(len(title)+1):
            markov_map[' '.join(title[max(0,i-lookback):i])][' '.join(title[i:i+1])] += 1

#Convert map to the word1 -> word2 -> probability of word2 after word1
for word, following in markov_map.items():
    total = float(sum(following.values()))
    for key in following:
        following[key] /= total

#Typical sampling from a categorical distribution
def sample(items):
    next_word = None
    t = 0.0
    for k, v in items:
        t += v
        if t and random() < v/t:
            next_word = k
    return next_word

def get_sentence(length_max=140):
    while True:
        sentence = []
        next_word = sample(markov_map[''].items())
        while next_word != '':
            sentence.append(next_word)
            next_word = sample(markov_map[' '.join(sentence[-lookback:])].items())
        sentence = ' '.join(sentence)
        if any(sentence in title for title in titles):
            continue #Prune titles that are substrings of actual titles
        if len(sentence) > length_max:
            continue
        return sentence

def retitlize_sentence(sentence):
    lowercase_sentence = sentence.split(" ")
    uppercase_sentence = []

    for word in lowercase_sentence:
        uppercase_sentence.append(titlecase_mappings.get(word, word))

    return " ".join(uppercase_sentence)

for _ in itertools.repeat(None, 10):
    print retitlize_sentence(get_sentence())