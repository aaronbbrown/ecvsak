#!/usr/bin/env ruby

require 'pp'
require 'net/https'
require 'rubygems'
require 'optparse'
require 'benchmark'
require 'faraday'
require 'faraday_middleware'

$stdout.sync = true

options = {}

opts = OptionParser.new
opts.banner = "Usage #{$0} -i ISP -c CDN input"
opts.on("-i ISP", String, "ISP Name") { |v| options[:isp] = v }
opts.on("-a", "using ADN") { |v| options[:adn] = v }
opts.on("-e HOSTNAME",  String, "Edge Hostname OR IP to test against") { |v| options[:edge] = v }
opts.on("-n ITERATIONS", Integer, "Number of iterations") { |v| options[:iterations] = v }
opts.on("-u USERNAME", String, "user name" ) { |v| options[:login] = v }
opts.on("-p PASSWORD", String, "password" ) { |v| options[:password] = v }
opts.parse!

def login ( login, password ) 
  uri = URI.parse("https://www.ideeli.com/login?MuttAndJeff=1")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Post.new(uri.request_uri)
  request.set_form_data( :login => login, :password => password )
  http.request(request)['set-cookie']
end 

# log in!
cookies = login(options[:login], options[:password])
unless cookies && cookies['current_user']
  $stderr.puts "Login failed"
  exit 1
end

puts "url_num,code,content-length,ms,isp,source"

conn = Faraday.new(:url => "http://#{options[:edge]}") do |c|
  c.use FaradayMiddleware::FollowRedirects
  c.adapter :net_http
  c.headers[:host] = 'www.ideeli.com'
  c.headers[:accept_encoding] = 'gzip,deflate'
  c.headers[:cookie] = cookies
end

ARGF.each_with_index do |url,i|
  resp = nil
  tm = nil
  options[:iterations].times do
    tm = Benchmark.realtime do 
      resp = conn.get url 
    end
    puts "#{i+1},#{resp.status},#{resp.headers['content-length'] || resp.body.length },#{tm*1000},#{options[:isp]},#{options[:adn] ? 'adn' : 'origin' }"
  end
end

