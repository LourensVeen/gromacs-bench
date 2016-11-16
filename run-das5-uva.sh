#!/bin/bash

# Script for running experiments on the UvA cluster of DAS-5

# Naming scheme: run_n<nodes>_t<TitanX_per_node>_g<GTX980_per_node>_i<interconnect>_r<replica>
# where <interconnect> is i for Infiniband, e for Ethernet

for REPLICA in `seq 1 10` ; do

	# CPU+GPU GTX980 runs with Infiniband
	for NUM_GPUS in 1 2 3 4 ; do
		sbatch -w node205 --gres=gpu:${NUM_GPUS} gromacs-bench.slurm run_n1_t0_g${NUM_GPUS}_ii_r${REPLICA} infiniband
		sbatch -w node205,node206 --gres=gpu:${NUM_GPUS} gromacs-bench.slurm run_n2_t0_g${NUM_GPUS}_ii_r${REPLICA} infiniband
	done
done

