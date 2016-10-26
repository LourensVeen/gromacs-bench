#!/bin/bash

echo 'Run name,Decomposition,Avg. atoms per domain,Min. atoms per domain,Max. atoms per domain,Atoms comm. per step force,Atoms comm. per step vsites,Atoms comm. per step LINCS,Performance (ns/day),Total core time,Wallclock time' >data.csv

for RUN_NAME in `ls -1 runs` ; do

	LOG="runs/$RUN_NAME/CYP19A1vs-MD.part0001.log"

	DECOMPOSITION=`grep '^Domain decomposition grid' ${LOG} | sed -e 's/^Domain decomposition grid //' | sed -e 's/, separate PME ranks .*//'`

	AVG_ATOMS_PER_DOMAIN=`grep '^Atom distribution over' ${LOG} | sed -e 's/^Atom distribution over [[:digit:]]* domains: av \([[:digit:]]*\) stddev [[:digit:]]* min [[:digit:]]* max [[:digit:]]*/\1/'`

	MIN_ATOMS_PER_DOMAIN=`grep '^Atom distribution over' ${LOG} | sed -e 's/^Atom distribution over [[:digit:]]* domains: av [[:digit:]]* stddev [[:digit:]]* min \([[:digit:]]*\) max [[:digit:]]*/\1/'`

	MAX_ATOMS_PER_DOMAIN=`grep '^Atom distribution over' ${LOG} | sed -e 's/^Atom distribution over [[:digit:]]* domains: av [[:digit:]]* stddev [[:digit:]]* min [[:digit:]]* max \([[:digit:]]*\)/\1/'`


	ATOMS_COMM_PER_STEP_FORCE=`grep '^ av. #atoms communicated per step for force:' ${LOG} | sed -e 's/^ av. #atoms communicated per step for force:  //'`

	ATOMS_COMM_PER_STEP_VSITES=`grep '^ av. #atoms communicated per step for vsites:' ${LOG} | sed -e 's/^ av. #atoms communicated per step for vsites: //'`

	ATOMS_COMM_PER_STEP_LINCS=`grep '^ av. #atoms communicated per step for LINCS:' ${LOG} | sed -e 's/^ av. #atoms communicated per step for LINCS:  //'`


	PERF_NS_DAY=`grep '^Performance:' ${LOG} | sed -e 's/^Performance:[[:space:]]*\([[:alnum:],.]*\).*/\1/'`

	PERF_TOTAL_CORE_TIME=`grep '^[[:space:]]*Time:' ${LOG} | sed -e 's/^[[:space:]]*Time:[[:space:]]*\([[:digit:],.]*\).*/\1/'`

	PERF_WALL_TIME=`grep '^[[:space:]]*Time:' ${LOG} | sed -e 's/^[[:space:]]*Time:[[:space:]]*[[:digit:],.]*[[:space:]]*\([[:digit:],.]*\).*/\1/'`

	echo -n "$RUN_NAME" >>data.csv

	echo -n ",$DECOMPOSITION" >>data.csv

	echo -n ",$AVG_ATOMS_PER_DOMAIN" >>data.csv 
	echo -n ",$MIN_ATOMS_PER_DOMAIN" >>data.csv 
	echo -n ",$MAX_ATOMS_PER_DOMAIN" >>data.csv 
	
	echo -n ",$ATOMS_COMM_PER_STEP_FORCE" >>data.csv 
	echo -n ",$ATOMS_COMM_PER_STEP_VSITES" >>data.csv 
	echo -n ",$ATOMS_COMM_PER_STEP_LINCS" >>data.csv 

	echo -n ",$PERF_NS_DAY" >>data.csv 
	echo -n ",$PERF_TOTAL_CORE_TIME" >>data.csv 
	echo -n ",$PERF_WALL_TIME" >>data.csv

	echo >>data.csv
done

