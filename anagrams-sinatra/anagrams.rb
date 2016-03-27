# - `POST /words.json`: Takes a JSON array of English-language words and adds them to the corpus (data store).
# - `GET /anagrams/:word.json`:
#   - Returns a JSON array of English-language words that are anagrams of the word passed in the URL.
#   - This endpoint should support an optional query param that indicates the maximum number of results to return.
# - `DELETE /words/:word.json`: Deletes a single word from the data store.
# - `DELETE /words.json`: Deletes all contents of the data store.
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

post '/words.json' do
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
