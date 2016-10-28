#!/bin/bash
#SBATCH --time=00:10:00


########################
### Helper functions ###
########################

function usage() {
	echo
	echo "Usage: $0 <run name> <interconnect>"
	echo "interconnect may be ethernet, infiniband, or ethinf for ethernet protocol on infiniband"
}


#####################
### Configuration ###
#####################

RUN_NAME="$1"
INTERCONNECT="$2"

if [ "a$RUN_NAME" == "a" ]; then
	echo "ERROR: No run name specified, aborting"
	usage
	exit 1
fi

if [ "a$INTERCONNECT" == "a" ]; then
	echo "ERROR: No interconnect specified, aborting"
	usage
	exit 1
fi

MCA_OPTS=''
if [ $INTERCONNECT == 'ethernet' ]; then
	MCA_OPTS='--mca btl self,tcp --mca btl_tcp_if_include eth0'
elif [ $INTERCONNECT == 'ethinf' ]; then
	MCA_OPTS='--mca btl self,tcp --mca btl_tcp_if_include ib0'
fi


####################
### Load modules ###
####################

. /etc/bashrc
. /etc/profile.d/modules.sh

module load fftw3/openmpi/gcc/64/3.3.4
module load openmpi/gcc/64/1.10.1
module load cuda75/blas/7.5.18
module load cuda75/fft/7.5.18
module load cuda75/gdk/352.79
module load cuda75/toolkit/7.5.18


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

echo "Interconnect: $INTERCONNECT" >>metadata.txt

###################
### Run GROMACS ###
###################

source ${HOME}/opt/gromacs5/bin/GMXRC.bash

${MPI_RUN} -np $NUM_RANKS --map-by node -v --display-map --display-allocation ${MCA_OPTS} ${GMXBIN}/gmx mdrun -nice 0 -deffnm CYP19A1vs-MD -c CYP19A1vs-MD.gro -cpi CYP19A1vs-MD.cpt -ntomp ${THREADS_PER_RANK} -noappend -maxh -1 >mdrun.out 2>mdrun.err


