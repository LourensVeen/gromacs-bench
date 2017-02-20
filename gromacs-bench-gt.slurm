#!/bin/bash
#SBATCH --time=00:10:00


########################
### Helper functions ###
########################

function usage() {
	echo
	echo "Usage: $0 <run name> <number of gpus>"
}


#####################
### Configuration ###
#####################

RUN_NAME="$1"

if [ "a$RUN_NAME" == "a" ]; then
	echo "ERROR: No run name specified, aborting"
	usage
	exit 1
fi

NUM_GPUS="$2"

if [ "a$NUM_GPUS" == "a" ]; then
	echo "ERROR: No number of GPUs specified, aborting"
	usage
	exit 1
fi


####################
### Load modules ###
####################

# . /etc/bashrc
# . /etc/profile.d/modules.sh

module load fftw3/openmpi/gcc/64/3.3.4
module load openmpi/gcc/64/1.10.1
module load cuda80/blas/8.0.44
module load cuda80/fft/8.0.44
module load cuda80/toolkit/8.0.44
module load gromacs/5.1.3-gcc

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/cm/shared/apps/fftw-3.3.5/lib

####################################
### Set up files and directories ###
####################################

cd ${HOME}/gromacs/bench/runs
rm -rf $RUN_NAME
mkdir -p $RUN_NAME
cd $RUN_NAME

cp ${HOME}/gromacs/bench/input/* .

###################################
### Calculate MPI configuration ###
###################################

RANKS_PER_NODE=4
THREADS_PER_RANK=8

NUM_RANKS=`echo "$SLURM_NNODES * $RANKS_PER_NODE" | bc`
NUM_THREADS=`echo "$NUM_RANKS * $THREADS_PER_RANK" | bc`

###################
### Set up GPUs ###
###################

LAST_GPU=$(($NUM_GPUS - 1))

export CUDA_VISIBLE_DEVICES=`seq -s, 0 $LAST_GPU`


####################
### Document run ###
####################

echo "Run: $RUN_NAME" >>metadata.txt
echo -n "Started at: " >>metadata.txt ; date >>metadata.txt
echo "Running on: $SLURM_CLUSTER_NAME" >>metadata.txt
echo "Nodes: $SLURM_JOB_NODELIST" >>metadata.txt

echo "Number of nodes: $SLURM_NNODES" >>metadata.txt
echo "MPI ranks per node: $RANKS_PER_NODE" >>metadata.txt
echo "OpenMP threads per rank: $THREADS_PER_RANK" >>metadata.txt
echo "Total ranks: $NUM_RANKS" >>metadata.txt
echo "Total threads: $NUM_THREADS" >>metadata.txt

echo "Number of GPUs per node: $NUM_GPUS" >>metadata.txt


###################
### Run GROMACS ###
###################

source ${HOME}/opt/gromacs2016/bin/GMXRC.bash

mpirun -x CUDA_VISIBLE_DEVICES -np $NUM_RANKS --map-by node -v --display-map --display-allocation ${GMXBIN}/gmx mdrun -nice 0 -deffnm CYP19A1vs-MD -c CYP19A1vs-MD.gro -cpi CYP19A1vs-MD.cpt -ntomp ${THREADS_PER_RANK} -noappend -maxh -1 >mdrun.out 2>mdrun.err

