#!/usr/bin/env ruby

require 'pp'
require 'rubygems'
require 'httparty'
require 'optparse'
require 'benchmark'

options = {}
opts = OptionParser.new
opts.banner = "Usage #{$0} -i ISP -c CDN input"
opts.on("-i ISP", String, "ISP Name") { |v| options[:isp] = v }
opts.on("-c CDN", String, "CDN Name") { |v| options[:cdn] = v }
opts.parse!

def hit_or_miss ( xcache )
  xcache =~ /hit/i ? "HIT" : "MISS"
end

puts "url_num,code,content-length,ms,hit/miss,isp,cdn"
ARGF.each_with_index do |url,i|
  resp = nil
  tm = nil
  until resp && hit_or_miss(resp.headers['x-cache']) == "HIT" do
    tm = Benchmark.realtime do 
      resp = HTTParty.get(url , :headers => {'Pragma' => 'akamai-x-cache-on',
                                             'Host'   => '0.icdn.ideeli.net' })
    end
    puts "#{i+1},#{resp.code},#{resp.headers['content-length']},#{tm*1000},#{hit_or_miss(resp.headers['x-cache'])},#{options[:isp]},#{options[:cdn]}"
  end
end
