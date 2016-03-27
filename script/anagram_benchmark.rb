#!/usr/bin/env ruby

# Benchmarking code for anagram API

################################################
# NOT INTENDED TO BE DISTRIBUTED TO CANDIDATES #
################################################

require_relative 'anagram_client'
require 'benchmark/bigo'
require 'zlib'

# number of words to post at a time
SLICE_SIZE = 100
# starting size
MIN_SIZE   = 10_000
# size between steps
STEP_SIZE  = 10_000

def words
  Zlib::GzipReader.open('dictionary.txt.gz') do |gz|
    gz.read.split("\n")
  end
end

def client
  @client ||= AnagramClient.new(ARGV)
end

def post_in_batches(array)
  array.each_slice(SLICE_SIZE) do |slice|
    client.post('/words.json', { 'words' => slice })
  end
end

# create words (batched)
Benchmark.bigo do |example|
  example.generator do |size|
    words.sample(size)
  end

  example.min_size = MIN_SIZE
  example.step_size = STEP_SIZE

  example.report('POST /words.json') do |array, size|
    post_in_batches(array)
  end

  example.chart! 'chart_anagram_post.html'

  example.compare!
end


# get anagrams for each word
Benchmark.bigo do |example|
  example.generator do |size|
    ary = words.sample(size)
    post_in_batches(ary)
    ary
  end

  example.min_size = MIN_SIZE
  example.step_size = STEP_SIZE

  example.report('GET /anagrams/:word.json') do |array, size|
    # get anagrams for every word
    array.each do |word|
      @client.get("/anagrams/#{word}.json")
    end
  end

  example.chart! 'chart_anagram_get.html'

  example.compare!
end


# delete all words
Benchmark.bigo do |example|
  example.generator do |size|
    ary = words.sample(size)
    post_in_batches(ary)
    ary
  end

  example.min_size = MIN_SIZE
  example.step_size = STEP_SIZE

  example.report('DELETE /words.json') do |array, size|
    @client.delete('/words.json')
  end

  example.chart! 'chart_anagram_delete.html'

  example.compare!
end
