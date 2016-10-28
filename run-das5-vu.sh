#!/bin/bash

# Script for running experiments on the VU cluster of DAS-5

# Naming scheme: run_n<nodes>_t<TitanX_per_node>_g<GTX980_per_node>_i<interconnect>_r<replica>
# where <interconnect> is i for Infiniband, e for Ethernet

for REPLICA in `seq 5` ; do

	# CPU only runs with Infiniband
	for NUM_NODES in 1 2 4 8 16 24 ; do
		sbatch -N $NUM_NODES -C cpunode gromacs-bench.slurm run_n${NUM_NODES}_t0_g0_ii_r${REPLICA} infiniband
	done

	# CPU+GPU TitanX runs with Infiniband
	for NUM_NODES in 1 2 4 6 8 ; do
		sbatch -N $NUM_NODES -C TitanX --gres=gpu:1 gromacs-bench.slurm run_n${NUM_NODES}_t1_g0_ii_r${REPLICA} infiniband
	done

	# CPU only with Ethernet
	for NUM_NODES in 1 2 4 6 8 ; do
		sbatch -N $NUM_NODES -C cpunode gromacs-bench.slurm run_n${NUM_NODES}_t0_g0_ie_r${REPLICA} ethernet
	done

	# CPU only with Ethernet over Infiniband
	for NUM_NODES in 1 2 4 6 8 ; do
		sbatch -N $NUM_NODES -C cpunode gromacs-bench.slurm run-n${NUM_NODES}_t0_g0_im_r${REPLICA} ethinf
	done
done

