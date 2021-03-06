#!/bin/bash

echo 'Run name,Num. nodes,Num. threads,Num. TitanX,Num. GTX980,Num. GTX1080,Interconnect,Decomposition,Avg. atoms per domain,Min. atoms per domain,Max. atoms per domain,Atoms comm. per step force,Atoms comm. per step vsites,Atoms comm. per step LINCS,% Decomposition,% Neighbor search,% Comm. Coord,% Force,% Comm. Force,% Wait GPU local,% Wait GPU nonlocal,% Constraints,Performance (ns/day),Total core time,Wallclock time,Which nodes' >data.csv

for RUN_NAME in `ls -1d runs/run*r[!0]*` ; do

	RUN_NAME=`echo ${RUN_NAME} | sed -e 's%^runs/%%'`
	LOG="runs/$RUN_NAME/CYP19A1vs-MD.part0001.log"
	METADATA="runs/$RUN_NAME/metadata.txt"

	NUM_NODES=`grep '^Number of nodes: ' ${METADATA} | sed -e 's/^Number of nodes: //'`
	WHICH_NODES=`grep '^Nodes: ' ${METADATA} | sed -e 's/^Nodes: //'`
	NUM_THREADS=`grep '^Total threads: ' ${METADATA} | sed -e 's/^Total threads: //'`
	INTERCONNECT=`grep '^Interconnect: ' ${METADATA} | sed -e 's/^Interconnect: //'`

	NUM_TITANX=0
	NUM_GTX980=0
	NUM_GPUS=`grep '^    Number of GPUs detected:' ${LOG} | sed -e 's/^    Number of GPUs detected:[[:space:]]*//'`
	if grep -q 'NVIDIA GeForce GTX TITAN X' ${LOG} ; then
		NUM_TITANX="$NUM_GPUS"
	elif grep -q 'NVIDIA GeForce GTX 980' ${LOG} ; then
		NUM_GTX980="$NUM_GPUS"
	elif grep -q 'NVIDIA GeForce GTX 1080' ${LOG} ; then
		NUM_GTX1080="$NUM_GPUS"
	fi

	DECOMPOSITION=`grep '^Domain decomposition grid' ${LOG} | sed -e 's/^Domain decomposition grid //' | sed -e 's/, separate PME ranks .*//'`

	AVG_ATOMS_PER_DOMAIN=`grep '^Atom distribution over' ${LOG} | sed -e 's/^Atom distribution over [[:digit:]]* domains: av \([[:digit:]]*\) stddev [[:digit:]]* min [[:digit:]]* max [[:digit:]]*/\1/'`

	MIN_ATOMS_PER_DOMAIN=`grep '^Atom distribution over' ${LOG} | sed -e 's/^Atom distribution over [[:digit:]]* domains: av [[:digit:]]* stddev [[:digit:]]* min \([[:digit:]]*\) max [[:digit:]]*/\1/'`

	MAX_ATOMS_PER_DOMAIN=`grep '^Atom distribution over' ${LOG} | sed -e 's/^Atom distribution over [[:digit:]]* domains: av [[:digit:]]* stddev [[:digit:]]* min [[:digit:]]* max \([[:digit:]]*\)/\1/'`


	ATOMS_COMM_PER_STEP_FORCE=`grep '^ av. #atoms communicated per step for force:' ${LOG} | sed -e 's/^ av. #atoms communicated per step for force:  //'`

	ATOMS_COMM_PER_STEP_VSITES=`grep '^ av. #atoms communicated per step for vsites:' ${LOG} | sed -e 's/^ av. #atoms communicated per step for vsites: //'`

	ATOMS_COMM_PER_STEP_LINCS=`grep '^ av. #atoms communicated per step for LINCS:' ${LOG} | sed -e 's/^ av. #atoms communicated per step for LINCS:  //'`


	PERC_DECOMP=`grep '^ Domain decomp.  ' ${LOG} | sed -e 's/^ Domain decomp.[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*\([^[:space:]]*\)/\1/'`

	PERC_NEIGHBOR_SEARCH=`grep '^ Neighbor search  ' ${LOG} | sed -e 's/^ Neighbor search[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*\([^[:space:]]*\)/\1/'`

	PERC_COMM_COORD=`grep '^ Comm. coord.  ' ${LOG} | sed -e 's/^ Comm. coord.[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*\([^[:space:]]*\)/\1/'`

	PERC_FORCE=`grep '^ Force    ' ${LOG} | sed -e 's/^ Force[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*\([^[:space:]]*\)/\1/'`

	PERC_WAITCOMM=`grep '^ Wait + Comm. F   ' ${LOG} | sed -e 's/^ Wait + Comm. F[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*\([^[:space:]]*\)/\1/'`

	PERC_WAITGPULOCAL=`grep '^ Wait GPU local   ' ${LOG} | sed -e 's/^ Wait GPU local[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*\([^[:space:]]*\)/\1/'`

	PERC_WAITGPUNONLOCAL=`grep '^ Wait GPU nonlocal   ' ${LOG} | sed -e 's/^ Wait GPU nonlocal[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*\([^[:space:]]*\)/\1/'`

	PERC_CONSTRAINTS=`grep '^ Constraints    ' ${LOG} | sed -e 's/^ Constraints[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*\([^[:space:]]*\)/\1/'`


	PERF_NS_DAY=`grep '^Performance:' ${LOG} | sed -e 's/^Performance:[[:space:]]*\([[:alnum:],.]*\).*/\1/'`

	PERF_TOTAL_CORE_TIME=`grep '^[[:space:]]*Time:' ${LOG} | sed -e 's/^[[:space:]]*Time:[[:space:]]*\([[:digit:],.]*\).*/\1/'`

	PERF_WALL_TIME=`grep '^[[:space:]]*Time:' ${LOG} | sed -e 's/^[[:space:]]*Time:[[:space:]]*[[:digit:],.]*[[:space:]]*\([[:digit:],.]*\).*/\1/'`

	echo -n "$RUN_NAME" >>data.csv

	echo -n ",$NUM_NODES" >>data.csv
	echo -n ",$NUM_THREADS" >>data.csv
	echo -n ",$NUM_TITANX" >>data.csv
	echo -n ",$NUM_GTX980" >> data.csv
	echo -n ",$NUM_GTX1080" >>data.csv
	echo -n ",$INTERCONNECT" >>data.csv

	echo -n ",$DECOMPOSITION" >>data.csv

	echo -n ",$AVG_ATOMS_PER_DOMAIN" >>data.csv 
	echo -n ",$MIN_ATOMS_PER_DOMAIN" >>data.csv 
	echo -n ",$MAX_ATOMS_PER_DOMAIN" >>data.csv 
	
	echo -n ",$ATOMS_COMM_PER_STEP_FORCE" >>data.csv 
	echo -n ",$ATOMS_COMM_PER_STEP_VSITES" >>data.csv 
	echo -n ",$ATOMS_COMM_PER_STEP_LINCS" >>data.csv 

	echo -n ",$PERC_DECOMP" >>data.csv
	echo -n ",$PERC_NEIGHBOR_SEARCH" >>data.csv
	echo -n ",$PERC_COMM_COORD" >>data.csv
	echo -n ",$PERC_FORCE" >>data.csv
	echo -n ",$PERC_WAITCOMM" >>data.csv
	echo -n ",$PERC_WAITGPULOCAL" >>data.csv
	echo -n ",$PERC_WAITGPUNONLOCAL" >>data.csv
	echo -n ",$PERC_CONSTRAINTS" >>data.csv

	echo -n ",$PERF_NS_DAY" >>data.csv 
	echo -n ",$PERF_TOTAL_CORE_TIME" >>data.csv 
	echo -n ",$PERF_WALL_TIME" >>data.csv

	echo -n ",\"$WHICH_NODES\"" >>data.csv

	echo >>data.csv
done

