Executed against EdgeCast:

    ./cdnbench.rb <(awk '{print "http://edgecasturl" $1}' event_images.txt | head -10000) > ec.csv

Run against Akamai:
    
    ./cdnbench.rb <(awk '{print "http://akamaiurl" $1}' event_images.txt | head -10000) > ak.csv


Generate results from csv.  This will read ec.csv and generate ec.png:

    gnuplot -e 'CDN="EdgeCast"' -e 'PREFIX="ec"' generic.plot


**Results from us-east-1**
Akamai Results:
![Akamai, size/ms](https://github.com/9minutesnooze/ecvsak/raw/master/ak_size_vs_ms.png)

EdgeCast Results:
![EdgeCast, size/ms](https://github.com/9minutesnooze/ecvsak/raw/master/ec_size_vs_ms.png)
