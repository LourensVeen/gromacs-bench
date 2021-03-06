set terminal png font 'Arial, 24' size 1600,900 background rgb "#ffffff"

set style line 100 lt -1 lw 2 lc rgb '#000000'

set border 3 front ls 100

set datafile separator ','

set grid back lw 2 x y
set xrange [0:24]
set x2range [0:768]
set yrange [0:210]
set xtics nomirror 4
set x2tics nomirror 128
set ytics nomirror 30


num_steps=50000

####################################

set output 'laptop_cmp.png'

set key off autotitle columnheader
set title 'Gromacs on a cluster node'
set autoscale x
# disable x2 label and tics, but reserve space to preserve alignment
set x2label ' '
set x2tics 10000,10000
set yrange [0:30]
set ytics 5
set ylabel 'Simulation speed (ns/day)'

set boxwidth 0.5
set style fill solid

barcolor(x) = (x == 0) ? (65536 * 64 + 128) : (256 * 174 + 239)

plot 'gpu_cmp_clean.csv' using 0:14:(barcolor($0)):xtic(18) every ::0::1 with boxes lc rgb variable notitle

####################################

set output 'cpus.png'

set key off autotitle columnheader
set title 'Gromacs on many CPUs'
set xlabel 'Cluster nodes'
set xrange [0:24]
set xtics nomirror 4
set x2label 'Threads'
set x2tics nomirror 128
set ylabel 'Simulation speed (ns/day)'
set ytics nomirror 30
set yrange [0:210]

plot \
	'data_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):22 \
		with points notitle lc rgb '#00aeef' pt 7 ps 3 \
	, 'means_clean.csv' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):17 \
		with lines notitle lc rgb '#00aeef' lw 3 \
	, 'laptop.csv' using 1:3 with points notitle lc rgb '#400080' pt 7 ps 3


####################################

set output 'cpus_timespent.png'

set yrange [0:10]
set ytics 1
set ylabel 'Time spent per step (ms)'
set key inside right top invert opaque

plot \
	'means_clean.csv' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):\
		($19 / num_steps * $9 * 1000 / 100) \
		with filledcurves above x1 title 'Decomposition' \
	, '' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):\
		($19 / num_steps * $9 * 1000 / 100):\
		($19 / num_steps * ($9+$10) * 1000 / 100) \
		with filledcurves title 'Neighbor search' \
	, '' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):\
		($19 / num_steps * ($9+$10) * 1000 / 100):\
		($19 / num_steps * ($9+$10+$11) * 1000 / 100) \
		with filledcurves title 'Comm. Coord.' \
	, '' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):\
		($19 / num_steps * ($9+$10+$11) * 1000 / 100):\
		($19 / num_steps * ($9+$10+$11+$12) * 1000 / 100) \
		with filledcurves title 'Calc. Force' \
	, '' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):\
		($19 / num_steps * ($9+$10+$11+$12) * 1000 / 100):\
		($19 / num_steps * ($9+$10+$11+$12+$13) * 1000 / 100) \
		with filledcurves title 'Comm. Force' \
	, '' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):\
		($19 / num_steps * ($9+$10+$11+$12+$13) * 1000 / 100):\
		($19 / num_steps * ($9+$10+$11+$12+$13+$16) * 1000 / 100) \
		with filledcurves title 'Constraints'



####################################

set output 'cpus_corehours.png'

set key off autotitle columnheader
set title 'Core hours for 1ns run'
set ylabel 'Core hours'
set autoscale y
set ytics autofreq

plot \
	'data_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):($23 * 10 / 3600) \
		with points notitle lc rgb '#00aeef' pt 7 ps 3 \
	, 'means_clean.csv' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):($18 * 10 / 3600) \
		with lines notitle lc rgb '#00aeef' lw 3 \
	, 'laptop.csv' using 1:($4 * 10 / 3600) with points notitle lc rgb '#400080' pt 7 ps 3


####################################

set output 'cpus_wallclock.png'

set title 'Wallclock time for 1ns run'
set ylabel 'Wallclock time (min)'

plot \
	'data_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):($24 * 10 / 60) \
		with points notitle lc rgb '#00aeef' pt 7 ps 3 \
	, 'means_clean.csv' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):($19 * 10 / 60) \
		with lines notitle lc rgb '#00aeef' lw 3



####################################

set output 'cpus_ethernet.png'

set key on inside right bottom box autotitle columnheader height 0.5
set title 'Influence of network'
set yrange [0:210]
set ytics nomirror 30
set ylabel 'Simulation speed (ns/day)'

plot \
	'data_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):22 \
		with points notitle lc rgb '#00aeef' pt 7 ps 3 \
	, 'means_clean.csv' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):17 \
		with lines title 'Infiniband' lc rgb '#00aeef' lw 3 \
	, 'data_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'ethernet') ? $2 : 0/0):22 \
		with points notitle lc rgb '#ef6e00' pt 7 ps 3 \
	, 'means_clean.csv' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'ethernet') ? $4 : 0/0):17 \
		with lines title 'Ethernet' lc rgb '#ef6e00' lw 3 \
	, 'laptop.csv' using 1:3 with points notitle lc rgb '#400080' pt 7 ps 3


####################################

set output 'ethernet_timespent.png'

set yrange [0:10]
set ytics 1
set ylabel 'Time spent per step (ms)'
set key inside right top invert opaque

plot \
	'means_clean.csv' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'ethernet') ? $4 : 0/0):\
		($19 / num_steps * $9 * 1000 / 100) \
		with filledcurves above x1 title 'Decomposition' \
	, '' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'ethernet') ? $4 : 0/0):\
		($19 / num_steps * $9 * 1000 / 100):\
		($19 / num_steps * ($9+$10) * 1000 / 100) \
		with filledcurves title 'Neighbor search' \
	, '' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'ethernet') ? $4 : 0/0):\
		($19 / num_steps * ($9+$10) * 1000 / 100):\
		($19 / num_steps * ($9+$10+$11) * 1000 / 100) \
		with filledcurves title 'Comm. Coord.' \
	, '' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'ethernet') ? $4 : 0/0):\
		($19 / num_steps * ($9+$10+$11) * 1000 / 100):\
		($19 / num_steps * ($9+$10+$11+$12) * 1000 / 100) \
		with filledcurves title 'Calc. Force' \
	, '' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'ethernet') ? $4 : 0/0):\
		($19 / num_steps * ($9+$10+$11+$12) * 1000 / 100):\
		($19 / num_steps * ($9+$10+$11+$12+$13) * 1000 / 100) \
		with filledcurves title 'Comm. Force' \
	, '' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'ethernet') ? $4 : 0/0):\
		($19 / num_steps * ($9+$10+$11+$12+$13) * 1000 / 100):\
		($19 / num_steps * ($9+$10+$11+$12+$13+$16) * 1000 / 100) \
		with filledcurves title 'Constraints'

####################################

set output 'gpu_cmp.png'

set key off autotitle columnheader
set title 'Gromacs on many GPUs'
set autoscale x
# disable x2 label and tics, but reserve space to preserve alignment
set x2label ' '
set x2tics 10000,10000

set yrange [0:210]
set ytics nomirror 30
set ylabel 'Simulation speed (ns/day)'

set boxwidth 0.5
set style fill solid

plot 'gpu_cmp_clean.csv' using 0:14:(barcolor($0)):xtic(18) with boxes lc rgb variable notitle

set xtics nomirror 128


####################################

set output 'cpus_gpu.png'

set key off autotitle columnheader
set title 'Gromacs on many CPUs, with 1 GPU per node'
set xrange [0:24]
set xtics nomirror 4
set x2label 'Threads'
set x2tics nomirror 128
set yrange [0:210]
set ytics nomirror 30
set ylabel 'Simulation speed (ns/day)'

plot \
	'data_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):22 \
		with points notitle lc rgb '#00aeef' pt 7 ps 3 \
	, 'means_clean.csv' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):17 \
		with lines notitle lc rgb '#00aeef' lw 3 \
	, 'data_clean.csv' using (($4 == 1 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):22 \
		with points notitle lc rgb '#009f00' pt 7 ps 3 \
	, 'means_clean.csv' using (($2 == 1 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):17 \
		with lines notitle lc rgb '#009f00' lw 3 \
	, 'laptop.csv' using 1:3 with points notitle lc rgb '#400080' pt 7 ps 3


####################################

set output 'gpus_timespent.png'

set xrange [0:12]
set xtics nomirror 2
set x2label 'Threads'
set x2range [0:384]
set x2tics nomirror 64
set ylabel 'Time spent per step (ms)'
set yrange [0:10]
set ytics 1

set key inside right top nobox invert opaque

plot \
	'means_clean.csv' using (($2 == 1 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):\
		($19 / num_steps * $9 * 1000 / 100) \
		with filledcurves above x1 title 'Decomposition' \
	, '' using (($2 == 1 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):\
		($19 / num_steps * $9 * 1000 / 100):\
		($19 / num_steps * ($9+$10) * 1000 / 100) \
		with filledcurves title 'Neighbor search' \
	, '' using (($2 == 1 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):\
		($19 / num_steps * ($9+$10) * 1000 / 100):\
		($19 / num_steps * ($9+$10+$11) * 1000 / 100) \
		with filledcurves title 'Comm. Coord.' \
	, '' using (($2 == 1 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):\
		($19 / num_steps * ($9+$10+$11) * 1000 / 100):\
		($19 / num_steps * ($9+$10+$11+$12) * 1000 / 100) \
		with filledcurves title 'Calc. Force' \
	, '' using (($2 == 1 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):\
		($19 / num_steps * ($9+$10+$11+$12) * 1000 / 100):\
		($19 / num_steps * ($9+$10+$11+$12+$13) * 1000 / 100) \
		with filledcurves title 'Comm. Force' \
	, '' using (($2 == 1 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):\
		($19 / num_steps * ($9+$10+$11+$12+$13) * 1000 / 100):\
		($19 / num_steps * ($9+$10+$11+$12+$13+$14) * 1000 / 100) \
		with filledcurves title 'Wait GPU local' \
	, '' using (($2 == 1 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):\
		($19 / num_steps * ($9+$10+$11+$12+$13+$14) * 1000 / 100):\
		($19 / num_steps * ($9+$10+$11+$12+$13+$14+$15) * 1000 / 100) \
		with filledcurves title 'Wait GPU nonlocal' \
	, '' using (($2 == 1 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):\
		($19 / num_steps * ($9+$10+$11+$12+$13+$14+$15) * 1000 / 100):\
		($19 / num_steps * ($9+$10+$11+$12+$13+$14+$15+$16) * 1000 / 100) \
		with filledcurves title 'Constraints'



####################################

set output 'practice.png'

set key on inside right bottom autotitle columnheader box height 0.5
set title 'Gromacs on Cartesius vs. Lisa (approximately)'
set xrange [0:24]
set xtics 4
set x2range [0:768]
set x2tics 128
set yrange [0:210]
set ytics nomirror 30
set ylabel 'Simulation speed (ns/day)'

plot \
	'data_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):22 \
		with points notitle lc rgb '#00aeef' pt 7 ps 3 \
	, 'means_clean.csv' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):17 \
		with lines title 'Cartesius CPU' lc rgb '#00aeef' lw 3 \
	, 'data_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'ethernet') ? $2 : 0/0):22 \
		with points notitle lc rgb '#ef6e00' pt 7 ps 3 \
	, 'means_clean.csv' using (($2 == 0 && $3 == 0 && stringcolumn(1) eq 'ethernet') ? $4 : 0/0):17 \
		with lines title 'Lisa CPU' lc rgb '#ef6e00' lw 3 \
	, 'data_clean.csv' using (($4 == 0 && $5 == 2 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):22 \
		with points notitle lc rgb '#ae00ef' pt 7 ps 3 \
	, 'means_clean.csv' using (($2 == 0 && $3 == 2 && stringcolumn(1) eq 'infiniband') ? $4 : 0/0):17 \
		with lines title 'Cartesius GPU' lc rgb '#ae00ef' lw 3 \
	, 'laptop.csv' using 1:($4 * 100 / 3600) with points notitle lc rgb '#400080' pt 7 ps 3

