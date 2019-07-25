#!/bin/bash

#SBATCH --job-name=spring2015_Z1_0
#SBATCH --constraint=skylake
#SBATCH --nodes=7
#SBATCH --ntasks-per-node=48
#SBATCH --mem=187G
#SBATCH --time=12:00:00
#SBATCH --mail-user=eolson@eoas.ubc.ca
#SBATCH --mail-type=ALL
#SBATCH --account=rrg-allen
# stdout and stderr file paths/names
#SBATCH --output=/scratch/eolson/results/spring2015_Z1_0/stdout
#SBATCH --error=/scratch/eolson/results/spring2015_Z1_0/stderr


RUN_ID="spring2015_Z1_0"
RUN_DESC="spring2015_Z1_0.yaml"
WORK_DIR="/scratch/eolson/spring2015_Z1_0_2018-09-30T034712.820953-0700"
RESULTS_DIR="/scratch/eolson/results/spring2015_Z1_0"
COMBINE="${HOME}/.local/bin/salishsea combine"
GATHER="${HOME}/.local/bin/salishsea gather"

module load netcdf-mpi/4.4.1.1
module load netcdf-fortran-mpi/4.4.4
module load python/3.7.0

mkdir -p ${RESULTS_DIR}
cd ${WORK_DIR}
echo "working dir: $(pwd)"

echo "Starting run at $(date)"
mpirun -np 317 ./nemo.exe : -np 1 ./xios_server.exe
MPIRUN_EXIT_CODE=$?
echo "Ended run at $(date)"

echo "Results combining started at $(date)"
${COMBINE} ${RUN_DESC} --debug
echo "Results combining ended at $(date)"

echo "Results gathering started at $(date)"
${GATHER} ${RESULTS_DIR} --debug
echo "Results gathering ended at $(date)"

chmod go+rx ${RESULTS_DIR}
chmod g+rw ${RESULTS_DIR}/*
chmod o+r ${RESULTS_DIR}/*

echo "Deleting run directory" >>${RESULTS_DIR}/stdout
rmdir $(pwd)
echo "Finished at $(date)" >>${RESULTS_DIR}/stdout
exit ${MPIRUN_EXIT_CODE}
