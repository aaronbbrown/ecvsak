set title "Akamai size vs time (floor)"
set logscale xy
set ylabel "content-length"
set xlabel "milliseconds"
set datafile separator ","
set pointsize 0.2

set terminal png font "/Library/Fonts/Arial.ttf"  size 1024,768
set output "ak_floor.png"

set style line 1 linecolor rgb "#55555"

plot "<grep -e ,HIT ak.csv" using (floor($4)):3 title "HIT" with points ls 1 
