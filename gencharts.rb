#!/usr/bin/env ruby

require 'pp'
require 'ftools'
require 'rubygems'
require 'rinruby'
require 'sequel'
require 'logger'

logger = Logger.new($stdout)
logger.level = Logger::INFO
width = 1024
height = 768

current_dir = File.expand_path(File.dirname(__FILE__))
source_csv = "#{current_dir}/raw/all.csv"
tmp_csv = '/tmp/all.csv'
tmp_csv_stdev = '/tmp/' + (0...8).map{65.+(rand(25)).chr}.join + '.csv'
stdev_csv = "#{current_dir}/raw/all_stdev.csv"

# generate stdev file
db = Sequel.connect( :host     => 'localhost',
                     :adapter  => 'mysql',
                     :port     => 3306,
                     :user     => 'root',
                     :database => 'test',
                     :logger   => logger)

tbl_name = "all_results"
create_table = <<SQL
CREATE TABLE `#{tbl_name}` (
  `url_id` int(10) unsigned DEFAULT NULL,
  `http_code` int(10) unsigned DEFAULT NULL,
  `content_length` int(10) unsigned DEFAULT NULL,
  `ms` float(12,2) DEFAULT NULL,
  `hit_miss` varchar(4) DEFAULT NULL,
  `cdn` varchar(20) DEFAULT NULL,
  `isp` varchar(20) DEFAULT NULL
) ENGINE=InnoDB
SQL

File.unlink(tmp_csv) if File.file?(tmp_csv)
File.unlink(tmp_csv_stdev) if File.file?(tmp_csv_stdev)
File.copy(source_csv,tmp_csv,true)

db["DROP TABLE IF EXISTS `#{tbl_name}`"].all
db[create_table].all
query = <<SQL
LOAD DATA INFILE '#{tmp_csv}' 
INTO TABLE `#{tbl_name}` 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
SQL
db[query].insert

query = <<SQL
SELECT isp, cdn, FLOOR(content_length/1000)*1000, STD(ms) 
FROM `#{tbl_name}`
WHERE hit_miss='HIT' 
GROUP BY 1,2,3 
HAVING STD(ms) > 0 
INTO OUTFILE '#{tmp_csv_stdev}'
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n';
SQL

db[query].all
File.unlink(stdev_csv) if File.file?(stdev_csv)
File.copy(tmp_csv_stdev,stdev_csv,true)


logger.info "Generating scatter plots"
R.echo false
R.eval <<EOF
  library('ggplot2')
  all <- read.csv('#{source_csv}')
  hits <- subset(all, all$hit.miss == 'HIT')
EOF

cdns = R.pull "as.character(unique(hits$cdn))"
cdns.each do |cdn|
  R.eval "hits_cdn <- subset(hits, hits$cdn == '#{cdn}')"
  isps = R.pull("as.character(unique(hits_cdn$isp))")

  isps.each do |isp|
    fn = "charts/#{cdn}_#{isp}.png"
    logger.info "Removing #{fn}"
    File.unlink(fn) if File.file?(fn)
    logger.info "Generating scatter plot for #{cdn} in #{isp} to #{fn}"
    R.eval <<EOF
      hits_isp_cdn <- subset(hits_cdn, hits_cdn$isp == '#{isp}')
      png('#{fn}',width=#{width},height=#{height})
      qplot(ms, content.length, data=hits_isp_cdn, 
        size=I(2/3),
        main='#{cdn} #{isp} time(ms) vs content-length')+
        scale_x_log10()+scale_y_log10()
EOF
  end
end

R.eval <<EOF
  all_stdev <- read.csv('#{stdev_csv}', head=FALSE)
  colnames(all_stdev) = c('isp', 'cdn', 'content_length', 'stdev')
EOF

isps = R.pull("as.character(unique(all_stdev$isp))")
isps.each do |isp|
  fn = "charts/stdev_smooth_#{isp}.png"
  logger.info "Generating smoothed stdev chart for #{isp} to #{fn}"
  R.eval <<EOF
    isp_stdev <- subset(all_stdev,all_stdev$isp == '#{isp}')
    png('#{fn}',width=#{width},height=#{height})
    qplot(content_length, stdev, 
        geom='smooth', 
        data=isp_stdev, 
        color=cdn,
        main="Standard Deviation of content-lengths in 1KB bins (#{isp})")
EOF
end
