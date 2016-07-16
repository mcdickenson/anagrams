#!/usr/bin/env ruby

require 'bundler/setup'
require_relative 'app'

#to allow uploading the entire dictionary
Rack::Utils.key_space_limit = 10*1024*1024

run Sinatra::Application
