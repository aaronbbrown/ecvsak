#!/usr/bin/env ruby

require 'pp'
require 'rubygems'
require 'rinruby'

R.echo false

R.eval <<EOF
  library('ggplot2')
  all <- read.csv('raw/all.csv')
  hits <- subset(all, all$hit.miss == 'HIT')
EOF

cdns = R.pull "as.character(unique(hits$cdn))"
cdns.each do |cdn|
  R.eval "hits_cdn <- subset(hits, hits$cdn == '#{cdn}')"
  isps = R.pull("as.character(unique(hits_cdn$isp))")

  isps.each do |isp|
    fn = "charts/#{cdn}_#{isp}.png"
    File.unlink(fn) if File.file?(fn)
    R.eval <<EOF
      hits_isp_cdn <- subset(hits_cdn, hits_cdn$isp == '#{isp}')
      png('#{fn}',width=1024,height=768)
      qplot(ms, content.length, data=hits_isp_cdn, 
        size=I(2/3),
        main='#{cdn} #{isp} time(ms) vs content-length')+
        scale_x_log10()+scale_y_log10()
EOF
  end
end
