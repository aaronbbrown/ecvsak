Executed against EdgeCast:

    ./cdnbench.rb <(awk '{print "http://edgecasturl" $1}' event_images.txt | head -10000)

Run against Akamai:
    
    ./cdnbench.rb <(awk '{print "http://akamaiurl" $1}' event_images.txt | head -10000)


**Results from us-east-1**
Akamai Results:
![Akamai, size/ms](https://github.com/9minutesnooze/ecvsak/raw/master/ak_size_vs_ms.png)

EdgeCast Results:
![EdgeCast, size/ms](https://github.com/9minutesnooze/ecvsak/raw/master/ec_size_vs_ms.png)
