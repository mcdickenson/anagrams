#!/usr/bin/env ruby

require_relative 'anagram_collection'

require 'sinatra'
require 'json'
require 'sinatra/reloader' if development?

get '/' do
  "PONG"
end

post '/words.json' do
  data = JSON.parse(request.body.read.to_s)
  data['words'].each do |word|
    AnagramCollection.instance.add(word)
  end
  status 201
end

get '/anagrams/:word.json' do
  content_type :json
  anagrams = AnagramCollection.instance.get(params['word'])
  anagrams = anagrams.take(params['limit'].to_i) if params['limit'].to_i > 0
  { anagrams: anagrams }.to_json
end

delete '/words.json' do
  AnagramCollection.instance.reset
  status 204
end

delete '/words/:word.json' do
  AnagramCollection.instance.delete(params['word'])
  status 200
end

get '/stats.json' do
  stats = AnagramCollection.instance.stats
  { stats: stats }.to_json
end

get '/stats/detailed.json' do
  bytes = `ps -o rss -p #{$$}`.strip.split.last.to_i * 1024

  {
    process_bytes: bytes
  }.to_json
end
