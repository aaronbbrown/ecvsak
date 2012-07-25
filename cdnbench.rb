#!/usr/bin/env ruby

require 'pp'
require 'rubygems'
require 'httparty'
require 'benchmark'

def hit_or_miss ( xcache )
  xcache =~ /hit/i ? "HIT" : "MISS"
end

timeout = 5

puts "url_num,code,content-length,ms,hit/miss"
ARGF.each_with_index do |url,i|
  resp = nil
  tm = nil
  until resp && hit_or_miss(resp.headers['x-cache']) == "HIT" do
    tm = Benchmark.realtime do 
      resp = HTTParty.get(url , :headers => {'Pragma' => 'akamai-x-cache-on'})
    end
    puts "#{i+1},#{resp.code},#{resp.headers['content-length']},#{tm*1000},#{hit_or_miss(resp.headers['x-cache'])}"
  end
end
