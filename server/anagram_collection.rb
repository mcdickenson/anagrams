require 'set'
require 'concurrent'

class AnagramCollection
  COLLECTION_MUTEX = Mutex.new

  attr_reader :total_chars, :count

  class << self
    def instance
      COLLECTION_MUTEX.synchronize do
        @instance ||= self.new
      end
    end
  end

  #reset entire collection
  def reset
    @collection = Concurrent::Map.new { |h, k| h[k] = Concurrent::Array.new }
    @total_chars = Concurrent::AtomicFixnum.new
    @count = Concurrent::AtomicFixnum.new
    self
  end

  #add a word
  # @param [String] word
  def add(word)
    key = word_key(word)
    set = @collection[key]
    if !set.include?(word)
      set << word
      @total_chars.increment(word.size) if @collection[key].size == 1
      @count.increment(1)
    end
    word
  end

  #get a word's anagrams
  # @param [String] word
  # @return [Array,nil] list of anagrams (sorted). Empty array if none
  def get(word)
    key = word_key(word)
    out = @collection[key]
    return [] unless out.size > 1
    (out - [word]).sort!
  end

  #delete a word
  # @param [String] word
  def delete(word)
    key = word_key(word)
    set = @collection[key]
    if set && set.include?(word)
      set.delete(word)
      @count.decrement(1)
      if set.size == 0
        @collection.delete(key)
        @total_chars.decrement(key.size)
      end
    end
    nil
  end

  #get some stats about the collection
  def stats
    {
      anagram_groups: @collection.size,
      count_words: @count.value,
      avg_length: (@total_chars.value/@collection.size),
      avg_num_anagrams: (@count.value/@collection.size),
      histogram: histogram,
    }
  end

  #get a histogram of number of anagrams
  def histogram
    num_anagrams = Hash[@collection.values.map(&:size).group_by { |v| v }.map { |k,v| [k, v.size] }]
    #remove 1-element
    num_anagrams = Hash[num_anagrams.map { |k,v| [k-1, v] }]
    num_anagrams.delete(0)

    num_anagrams
  end

  private

  def initialize
    reset
  end

  #hash key for word
  # @param [String] word
  def word_key(word)
    word.split('').sort.join('')
  end

end
