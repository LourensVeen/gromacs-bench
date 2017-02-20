#!/bin/bash

# Script for running experiments on the VU GT cluster

# Naming scheme: run_n<nodes>_G<GTX1080_per_node>_r<replica>

module load slurm

for REPLICA in `seq 1 5` ; do
	# CPU+GPU runs
	for NUM_NODES in 1 2 ; do
		for NUM_GPUS in 1 2 4 ; do
			sbatch -N $NUM_NODES -p gpu gromacs-bench-gt.slurm run_n${NUM_NODES}_G${NUM_GPUS}_r${REPLICA} $NUM_GPUS
		done
	done
done

