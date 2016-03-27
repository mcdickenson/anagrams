require 'sinatra'
require 'redis'
require 'hiredis'
require 'json'

helpers do
  def key(word)
    word.split('').sort.join
  end

  def redis
    @redis ||= Redis.new(:driver => :hiredis)
  end
end

# Add words to corpus
post '/words.:format?' do
  request.body.rewind
  data = JSON.parse(request.body.read)

  # if no words were passed, unprocessable entity
  unless data['words']
    return status 422
  end

  data['words'].each do |word|
    redis.sadd(key(word), word)
  end

  status 201
end

# Get anagrams for a word
get '/anagrams/:word.:format?' do
  word = params['word']
  anagrams = if params['limit']
    # if we only want a subset, make it a random subset (faster than retrieving the whole set)
    redis.srandmember(key(word), params['limit'].to_i)
  else
    # don't include word as its own anagram
    redis.smembers(key(word)) - [word]
  end
  anagrams ||= []

  { anagrams: anagrams }.to_json
end

# Delete all words
delete '/words.:format?' do
  redis.flushall
  status 204
end

# Delete single word
delete '/words/:word.:format?' do
  word = params['word']
  redis.srem(key(word), word)
end