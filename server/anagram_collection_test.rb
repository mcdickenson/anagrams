#!/usr/bin/env ruby

require 'bundler/setup'
require 'set'
require 'test/unit'

require_relative 'anagram_collection'

class TestCases < Test::Unit::TestCase

  attr_reader :collection

  # runs before each test
  def setup
    @collection = AnagramCollection.instance
  end

  # runs after each test
  def teardown
    # delete everything
    @collection.reset
  end

  def test_add_get_single
    collection.add('word')
    output = collection.get('word')
    assert_equal([], output)
  end

  def test_add_get_anagram
    collection.add('reed')
    collection.add('deer')
    output = collection.get('reed')
    assert_equal(['deer'], output)
    output = collection.get('deer')
    assert_equal(['reed'], output)
    output = collection.get('dee')
    assert_equal([], output)
  end

  def test_add_get_multiple_anagrams
    collection.add('reed')
    collection.add('deer')
    collection.add('trap')
    collection.add('part')
    collection.add('tarp')

    output = collection.get('reed')
    assert_equal(['deer'], output)
    output = collection.get('deer')
    assert_equal(['reed'], output)

    output = collection.get('part')
    assert_equal(['tarp', 'trap'], output)
    output = collection.get('trap')
    assert_equal(['part', 'tarp'], output)
  end

  def test_delete
    collection.add('trap')
    collection.add('part')
    collection.add('tarp')

    output = collection.get('part')
    assert_equal(['tarp', 'trap'], output)

    collection.delete('tarp')

    output = collection.get('part')
    assert_equal(['trap'], output)

    collection.delete('other')

    output = collection.get('part')
    assert_equal(['trap'], output)
  end

  def test_add_get_anagram_duplicate
    collection.add('reed')
    collection.add('reed')
    collection.add('deer')
    collection.add('deer')
    output = collection.get('reed')
    assert_equal(['deer'], output)
    output = collection.get('deer')
    assert_equal(['reed'], output)
    output = collection.get('dee')
    assert_equal([], output)
  end

  def test_histogram
    collection.add('trap')
    collection.add('part')
    collection.add('tarp')

    assert_equal({2=>1}, collection.histogram)
  end

end
