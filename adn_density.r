library('ggplot2')
all <- read.csv('raw/origin_adn_latest.txt')
twc <- subset(all, all$isp=='twcny')
png('charts/adn_twcny_latest.png', 1200,720)
qplot(ms, data=all, fill=source,geom="density",alpha=I(0.4),main="Response Time Density (TWC)\n/events/latest")+scale_x_log10(breaks=seq(0,1000,100),limits=c(200,2000))

