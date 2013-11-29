from collections import defaultdict
from random import random
import os
import itertools

"""
PLEASE DO NOT RUN THIS QUOTED CODE FOR THE SAKE OF daemonology's SERVER, IT IS
NOT MY SERVER AND I FEEL BAD FOR ABUSING IT. JUST GET THE RESULTS OF THE
CRAWL HERE: http://pastebin.com/raw.php?i=nqpsnTtW AND SAVE THEM TO "archive.txt"

import urllib2
import re
import sys

archive = open("archive.txt","w")

for year in xrange(1,4):
    for month in xrange(1,13):
        for day in xrange(1,32):
            try:
                print "http://www.daemonology.net/hn-daily/201%d-%02d-%02d.html" % (year, month, day)
                response = urllib2.urlopen("http://www.daemonology.net/hn-daily/201%d-%02d-%02d.html" % (year, month, day))
                html = response.read()
                titles = re.findall(r'ylink"><[^>]*>([^<]*)', html)
                for title in titles:
                    archive.write(title+"\n")
            except:
                #Invalid dates, could make this less hacky... but... meh
                pass
archive.close()

"""

dir = os.path.dirname(__file__)
filename = os.path.join(dir, "dictionaries/hackernews.txt")

archive = open(filename)
titles = archive.read().split("\n")
archive.close()
markov_map = defaultdict(lambda:defaultdict(int))

lookback = 2

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


for _ in itertools.repeat(None, 10):
    print get_sentence()