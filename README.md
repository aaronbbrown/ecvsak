Executed against EdgeCast:

    ./cdnbench.rb -c edgecast -i us-east-1 <(awk '{print "http://edgecasturl" $1}' event_images.txt | head -10000) >> all.csv

Run against Akamai:
    
    ./cdnbench.rb -c akamai -i us-east-1 <(awk '{print "http://akamaiurl" $1}' event_images.txt | head -10000) >> all.csv


Generate results from csv.  This will read ec.csv and generate ec.png:

    gnuplot -e 'CDN="EdgeCast"' -e 'PREFIX="ec"' generic.plot

R plots generated with
 
    ./genplots.rb

R plots assume a working MySQL instance that has read/write access to /tmp and script is executed as a local user with read/write access to /tmp
