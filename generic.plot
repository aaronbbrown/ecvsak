set title CDN." size vs time (".PREFIX.")"
set logscale xy
set ylabel "content-length"
set xlabel "milliseconds"
set datafile separator ","
set pointsize 0.15

set terminal png font "/Library/Fonts/Arial.ttf"  size 1024,768
set output PREFIX.".png"

set style line 1 linecolor rgb "#55555"

plot "<grep -e ,HIT ".PREFIX.".csv" using 4:3 title "HIT" with points ls 1 
