set terminal png font 'Arial, 24' size 1600,900 background rgb "#ffffff"

set style line 100 lt -1 lw 2 lc rgb '#000000'

set border 3 front ls 100

set datafile separator ','

set grid back lw 2 x y
set xrange [0:24]
set x2range [0:768]
set yrange [0:200]
set xtics nomirror 4
set x2tics nomirror 128
set ytics nomirror

####################################

set output 'cpus.png'

set key off autotitle columnheader
set title 'Gromacs on many CPUs'
set xlabel 'Cluster nodes'
set x2label 'Threads'
set ylabel 'Simulation speed (ns/day)'

plot \
	'data_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):14 \
		with points notitle lc rgb '#00aeef' pt 7 ps 3 \
	, 'means_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):14 \
		with lines notitle lc rgb '#00aeef' lw 3

####################################

set output 'cpus_ethernet.png'

set key on inside right bottom autotitle columnheader box height 1.5
set title 'Influence of network'

plot \
	'data_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):14 \
		with points notitle lc rgb '#00aeef' pt 7 ps 3 \
	, 'means_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):14 \
		with lines title 'Infiniband' lc rgb '#00aeef' lw 3 \
	, 'data_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'ethernet') ? $2 : 0/0):14 \
		with points notitle lc rgb '#ef6e00' pt 7 ps 3 \
	, 'means_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'ethernet') ? $2 : 0/0):14 \
		with lines title 'Ethernet' lc rgb '#ef6e00' lw 3

####################################

set output 'gpu_cmp.png'

set key off autotitle columnheader
set title 'Gromacs on many GPUs'
set autoscale x
unset x2tics

set boxwidth 0.5
set style fill solid

plot 'gpu_cmp_clean.csv' using 0:14:xtic(18) with boxes lc rgb '#00aeef' notitle

set xtics nomirror 128

####################################

set output 'cpus_gpu.png'

set key off autotitle columnheader
set title 'Gromacs on many CPUs, with 1 GPU per 32 threads'
set xrange [0:24]
set xtics nomirror 4
set x2tics nomirror 128

plot \
	'data_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):14 \
		with points notitle lc rgb '#00aeef' pt 7 ps 3 \
	, 'means_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):14 \
		with lines notitle lc rgb '#00aeef' lw 3 \
	, 'data_clean.csv' using (($4 == 1 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):14 \
		with points notitle lc rgb '#009f00' pt 7 ps 3 \
	, 'means_clean.csv' using (($4 == 1 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):14 \
		with lines notitle lc rgb '#009f00' lw 3

####################################

set output 'practice.png'

set key on inside right bottom autotitle columnheader box height 1.5
set title 'Gromacs on Cartesius vs. Lisa (approximately)'

plot \
	'data_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):14 \
		with points notitle lc rgb '#00aeef' pt 7 ps 3 \
	, 'means_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):14 \
		with lines title 'Cartesius CPU' lc rgb '#00aeef' lw 3 \
	, 'data_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'ethernet') ? $2 : 0/0):14 \
		with points notitle lc rgb '#ef6e00' pt 7 ps 3 \
	, 'means_clean.csv' using (($4 == 0 && $5 == 0 && stringcolumn(6) eq 'ethernet') ? $2 : 0/0):14 \
		with lines title 'Lisa CPU' lc rgb '#ef6e00' lw 3 \
	, 'data_clean.csv' using (($4 == 0 && $5 == 2 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):14 \
		with points notitle lc rgb '#ae00ef' pt 7 ps 3 \
	, 'means_clean.csv' using (($4 == 0 && $5 == 2 && stringcolumn(6) eq 'infiniband') ? $2 : 0/0):14 \
		with lines title 'Cartesius GPU' lc rgb '#ae00ef' lw 3

